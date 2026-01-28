#!/bin/bash
set -e

echo "🚀 Starting Libratech Lab. Dotfiles Setup (2026)..."

# 1. Homebrew Installation
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f "/opt/homebrew/bin/brew" ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; fi
fi

# 2. Bundle Install
echo "📦 Bundling packages..."
brew bundle --file=./Brewfile

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
mise use --global node@lts
mise use --global python@3.12

# 5. Smart Stow Linking (with Auto-Backup)
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
        local relative_path=$(basename "$source_path")
        local target_path="$HOME/$relative_path"
        # 衝突チェックとバックアップ実行
        backup_if_exists "$target_path"
    done
    # 安全に Stow を実行
    stow -v --restow "$package"
done

# 6. TPM Setup
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ni (npm i replacement)
if ! command -v ni &> /dev/null; then
    log "Installing ni (via npm)..."
    npm install -g @antfu/ni || log_warning "Failed to install ni"
else
    log "ni is already installed, skipping"
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
# 9. Global NPM Packages
if command -v npm &> /dev/null; then
    echo "📦 Installing global npm packages..."
    npm install -g @devcontainers/cli
fi

# 10. Ghostty Configuration (Terminal Emulator)
echo "👻 Setting up Ghostty configuration..."
mkdir -p "$HOME/.config/ghostty"
ln -sf "$HOME/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"


echo "🎉 Setup Complete! Run 'exec zsh' to start."
