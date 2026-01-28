# Zsh設定ファイル（フレームワーク排除、軽量化）

# ============================================================================
# 基本設定
# ============================================================================

# 履歴設定
# XDGの履歴ディレクトリは対話シェルで作成（非対話の副作用を回避）
if [[ ! -d "${XDG_DATA_HOME}/zsh" ]]; then
  mkdir -p "${XDG_DATA_HOME}/zsh"
fi
HISTFILE="${XDG_DATA_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt HIST_VERIFY

# 補完設定
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION"

# 対話シェルでコメントを有効化
setopt interactive_comments

# ============================================================================
# ツール初期化
# ============================================================================

# DevContainer環境検出 & Mise設定
# コンテナ内ではMise管理バージョンではなく、システム標準(Dockerfile由来)のツールを優先する
if [[ -n "$REMOTE_CONTAINERS" ]] || [[ -f "/.dockerenv" ]]; then
  export MISE_NODE_VERSION="system"
  export MISE_PYTHON_VERSION="system"
fi

# mise (asdf互換のランタイム管理)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# starship プロンプト
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# zoxide (cdの代替)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# ============================================================================
# エイリアス: ツール置き換え
# ============================================================================

# ls -> eza
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree --level=2 --icons --git'      # 基本のTree表示
  alias ltt='eza --tree --level=4 --icons --git'     # 深い階層まで見る
  alias lta='eza --tree --level=2 --icons --git -a'  # 全て見る
fi

# cat -> bat
if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# grep -> ripgrep
if command -v rg &> /dev/null; then
  alias grep='rg'
fi

# vim系 -> nvim
if command -v nvim &> /dev/null; then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
fi

# c -> claude (Claude Code)
if command -v claude &> /dev/null; then
  alias c='claude'
fi

# ============================================================================
# エイリアス: 機能ショートカット
# ============================================================================

# zshrc の再読み込み
alias src='source ~/.zshrc'

# tmuxinator の短縮
if command -v tmuxinator &> /dev/null; then
  alias mux="tmuxinator"
fi

# Git エイリアス
if command -v git &> /dev/null; then
  alias ga='git add .'
  alias gau='git add -u'
  alias gc='git commit -v'
  alias gca='git commit --amend'
  alias gcm='git commit -m'
  alias gp='git push'
  alias gpf='git push --force-with-lease'
  alias gl='git lg'
  alias gs='git status'
  alias gd='git diff'
fi

# Lazygit エイリアス
if command -v lazygit &> /dev/null; then
  alias g='lazygit'
fi

# ============================================================================
# 関数定義
# ============================================================================

# --- DevContainer 関数 ---
# dotfiles関連のオプション（共通）
typeset -a devcontainer_dotfiles_opts=(
  --dotfiles-repository "https://github.com/libra-tech-japan/dotfiles"
  --dotfiles-target-path "~/dotfiles"
  --dotfiles-install-command "./install.sh"
)

# devup: DevContainerにdotfilesを注入して起動
function devup() {
  local workspace="${1:-.}"
  echo "🚀 Starting DevContainer with Dotfiles Injection..."
  devcontainer up \
    --workspace-folder "$workspace" \
    ${devcontainer_dotfiles_opts[@]}

  if [ $? -eq 0 ]; then
    echo "✅ Container Ready. Run 'devshell' to enter."
  fi
}

# devbuild: DevContainerをビルド
# 注: dotfilesの注入はdevcontainer upの段階で行われる
function devbuild() {
  local workspace="${1:-.}"
  echo "🔨 Building DevContainer..."
  devcontainer build \
    --workspace-folder "$workspace"

  if [ $? -eq 0 ]; then
    echo "✅ Container Built. Run 'devup' to start with dotfiles injection."
  fi
}

# devdotfiles: コンテナ内でdotfilesを更新（git pull & install）
function devdotfiles() {
  local workspace="${1:-.}"
  echo "🔄 Updating dotfiles inside DevContainer..."
  devcontainer exec \
    --workspace-folder "$workspace" \
    zsh -c "cd ~/dotfiles && git pull && ./install.sh"
}

# devshell: コンテナ内に入るショートカット
function devshell() {
  local workspace="${1:-.}"
  devcontainer exec --workspace-folder "$workspace" zsh || \
  devcontainer exec --workspace-folder "$workspace" bash
}

# --- tmux 関数 ---
# t: tmuxセッション 'main' にアタッチ、なければ作成
function t() {
  if [[ -n "$TMUX" ]]; then
    echo "Already in Tmux."
    return
  fi
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
}
