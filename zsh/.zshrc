# Zsh設定ファイル（フレームワーク排除、軽量化）

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

# エイリアス
# ls -> eza
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  # 基本のTree表示 (lt)
  alias lt='eza --tree --level=2 --icons --git'
  # 深い階層まで見る (ltt)
  alias ltt='eza --tree --level=4 --icons --git'
  # 全て見る (lta)
  alias lta='eza --tree --level=2 --icons --git -a'
fi

# cat -> bat
if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# grep -> ripgrep
if command -v rg &> /dev/null; then
  alias grep='rg'
fi

# v -> nvim
if command -v nvim &> /dev/null; then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
fi

# DevContainer 関数
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

# devbuild: DevContainerにdotfilesを注入してビルド
function devbuild() {
  local workspace="${1:-.}"
  echo "🔨 Building DevContainer with Dotfiles Injection..."
  devcontainer build \
    --workspace-folder "$workspace" \
    ${devcontainer_dotfiles_opts[@]}

  if [ $? -eq 0 ]; then
    echo "✅ Container Built. Run 'devup' to start."
  fi
}

# devshell: コンテナ内に入るショートカット
function devshell() {
  local workspace="${1:-.}"
  devcontainer exec --workspace-folder "$workspace" zsh || \
  devcontainer exec --workspace-folder "$workspace" bash
}

# tmux:'t'
function t() {
  if [[ -n "$TMUX" ]]; then
    echo "Already in Tmux."
    return
  fi
  # 'main' という名前のセッションにアタッチ、なければ作成
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
}

# tmuxinator の短縮
if command -v tmuxinator &> /dev/null; then
  alias mux="tmuxinator"
fi

# zshrc の再読み込み
alias src='source ~/.zshrc'

# --- Git & Lazygit Aliases (Defensive) ---
# Git 本体がある場合のみ定義
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

# Lazygit がある場合のみ定義
if command -v lazygit &> /dev/null; then
  alias g='lazygit'
fi


# Enable comments in interactive shell
setopt interactive_comments
