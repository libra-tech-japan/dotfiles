#!/bin/bash
set -e

echo "🚀 Starting Libratech Lab. Dotfiles Setup (2026)..."

# リポジトリルートに移動（どこから実行しても Stow / 相対パスを正しく解決）
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# 単一実行のためロックを取得（二重実行による brew のロック競合を防止）
INSTALL_LOCK="$DOTFILES_ROOT/.install.lock"
exec 200>"$INSTALL_LOCK"
if ! flock -n 200; then
    echo "⚠️  Another install is already running. Wait for it to finish or remove $INSTALL_LOCK and retry."
    exit 1
fi

# 0. コードベース内の .DS_Store を削除（Stow 競合防止）
if find "$DOTFILES_ROOT" -name '.DS_Store' -type f 2>/dev/null | grep -q .; then
    echo "🧹 Removing .DS_Store files in dotfiles..."
    find "$DOTFILES_ROOT" -name '.DS_Store' -type f -delete
fi

# 1. Homebrew Installation
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f "/opt/homebrew/bin/brew" ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; fi
fi
# Linux: 既に brew が入っていても PATH に入っていないことがあるため、bundle 前に確実に設定
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; fi

# 2. Bundle Install
echo "📦 Bundling packages..."
brew bundle --file=./Brewfile || {
    echo ""
    echo "⚠️  brew bundle failed. If you saw 'already locked' errors:"
    echo "   Another install or brew process may be running. Wait for it to finish, then run ./install.sh again."
    exit 1
}

# 2.1 Gitのグローバル除外ファイルを用意
if [ ! -f "$HOME/.gitignore_global" ]; then
    touch "$HOME/.gitignore_global"
fi

# 3. Docker & WSL Setup
if [ "$(uname)" == "Darwin" ]; then
    echo "🍎 macOS detected. Ensure OrbStack is running."
elif [ -f /etc/debian_version ]; then
    if ! command -v docker &> /dev/null; then
        echo "🐧 Linux detected. Installing Docker Engine..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
    fi
    if grep -q "microsoft" /proc/version; then
        echo "🪟 WSL2 detected. Setting up win32yank..."
        if ! command -v win32yank.exe &> /dev/null; then
            curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
            # 既定の配置先を作成
            mkdir -p "$HOME/.local/bin"
            if command -v unzip &> /dev/null; then
                unzip -p /tmp/win32yank.zip win32yank.exe > "$HOME/.local/bin/win32yank.exe"
            elif command -v bsdtar &> /dev/null; then
                bsdtar -xOf /tmp/win32yank.zip win32yank.exe > "$HOME/.local/bin/win32yank.exe"
            else
                echo "⚠️  unzip/bsdtar が無いため win32yank を展開できません"
                echo "    brew install unzip を実行してください"
                exit 1
            fi
            chmod +x "$HOME/.local/bin/win32yank.exe"
        fi
    fi
fi

# 4. Runtime Setup
echo "🔧 Setting up Runtimes..."
eval "$(mise activate bash)"
if command -v volta &> /dev/null; then
    echo "⚡ Volta detected. Skipping global Node setup via Mise to respect local environment."
else
    mise use --global node@lts
fi
mise use --global python@3.12

# 5. Smart Stow Linking (with Auto-Backup)
# カレントは既に DOTFILES_ROOT（Stow のベストプラクティス: リポジトリルートで stow 実行）
echo "🔗 Linking dotfiles..."
STOW_DIRS=("git" "lazygit" "nvim" "starship" "tmux" "zsh")

# バックアップ関数
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "⚠️  Conflict detected: Moving existing $target to $backup_name"
        mv "$target" "$backup_name"
    fi
}

for package in "${STOW_DIRS[@]}"; do
    # パッケージ内のトップレベルファイル/ディレクトリに対してチェックを行う
    # 注意: 隠しファイルも含めるため find を使用
    find "$package" -maxdepth 1 -mindepth 1 | while read -r source_path; do
        # "zsh/.zshrc" -> ".zshrc"
        relative_path=$(basename "$source_path")
        target_path="$HOME/$relative_path"
        # 衝突チェックとバックアップ実行
        backup_if_exists "$target_path"
    done
    # 安全に Stow を実行（カレントは DOTFILES_ROOT、ターゲットは $HOME）
    stow -v --restow "$package"
done

# Stow 後チェック: .config/nvim が無いと Neovim が設定を読まない
if [[ ! -e "$HOME/.config/nvim" ]]; then
    echo "⚠️  .config/nvim がありません。手動でリンクを作成しています..."
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_ROOT/nvim/.config/nvim" "$HOME/.config/nvim"
fi
if [[ ! -e "$HOME/.config/lazygit" ]]; then
    echo "⚠️  .config/lazygit がありません。手動でリンクを作成しています..."
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_ROOT/lazygit/.config/lazygit" "$HOME/.config/lazygit"
fi
if [[ ! -e "$HOME/.config/mise" ]]; then
    echo "⚠️  .config/mise がありません。手動でリンクを作成しています..."
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_ROOT/lazygit/.config/mise" "$HOME/.config/mise"
fi

# 6. TPM Setup
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ni (npm i replacement)
if ! command -v ni &> /dev/null; then
    echo "Installing ni (via npm)..."
    npm install -g @antfu/ni || echo "⚠️ Failed to install ni"
else
    echo "ni is already installed, skipping"
fi



# 7. VS Code Setup (macOS)
if [ "$(uname)" == "Darwin" ] && [ -d "$HOME/Library/Application Support/Code/User" ]; then
    echo "💻 Linking VS Code settings..."
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
    # settings.json
    ln -sf "$HOME/dotfiles/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
    # keybindings.json
    ln -sf "$HOME/dotfiles/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
    # snippets (Directory)
    if [ -d "$HOME/dotfiles/vscode/snippets" ]; then
        rm -rf "$VSCODE_USER_DIR/snippets"
        ln -sf "$HOME/dotfiles/vscode/snippets" "$VSCODE_USER_DIR/snippets"
    fi
    # Extensions Install
    if [ -f "$HOME/dotfiles/vscode/extensions.txt" ] && command -v code &> /dev/null; then
        echo "🧩 Installing VS Code extensions..."
        # 並列インストールで高速化
        cat "$HOME/dotfiles/vscode/extensions.txt" | xargs -L 1 -P 4 code --install-extension
    fi
fi
# 8. VS Code Setup (WSL2)
if [ -f /proc/version ] && grep -q "microsoft" /proc/version; then
    echo "🪟 WSL2 detected. Linking VS Code settings to Windows side..."
    # Windowsの %APPDATA% パスを取得し、WSLパス形式 (/mnt/c/...) に変換
    # cmd.exe を経由して正確なパスを取得します
    WIN_APPDATA=$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
    VSCODE_USER_DIR=$(wslpath -u "$WIN_APPDATA")/Code/User
    if [ -d "$VSCODE_USER_DIR" ]; then
        # settings.json
        ln -sf "$HOME/dotfiles/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
        # keybindings.json
        ln -sf "$HOME/dotfiles/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
        # snippets
        if [ -d "$HOME/dotfiles/vscode/snippets" ]; then
            rm -rf "$VSCODE_USER_DIR/snippets"
            ln -sf "$HOME/dotfiles/vscode/snippets" "$VSCODE_USER_DIR/snippets"
        fi
        # Extensions Install (Windows側のVS Codeに対してコマンド実行)
        if [ -f "$HOME/dotfiles/vscode/extensions.txt" ] && command -v code &> /dev/null; then
            echo "🧩 Installing VS Code extensions..."
            # WSL上の 'code' コマンドは、Windows側のRemote Server経由でインストールを実行します
            cat "$HOME/dotfiles/vscode/extensions.txt" | xargs -L 1 -P 4 code --install-extension
        fi
        echo "✅ VS Code settings linked to Windows AppData."
    else
        echo "⚠️  VS Code User directory not found in Windows. Skipping."
    fi
fi
# 9. Ghostty Configuration (Terminal Emulator)
echo "👻 Setting up Ghostty configuration..."
mkdir -p "$HOME/.config/ghostty"
ln -sf "$HOME/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"


echo "🎉 Setup Complete! Run 'exec zsh' to start."
