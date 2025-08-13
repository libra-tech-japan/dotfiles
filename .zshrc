# =============================================================================
# Powerlevel10k Instant Prompt
# =============================================================================
if [[ -s "${ZDOTDIR:-$HOME}/.p10k/powerlevel10k.zsh-theme" ]]; then
  source "${ZDOTDIR:-$HOME}/.p10k/powerlevel10k.zsh-theme"
fi
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Prezto
# =============================================================================
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# =============================================================================
# Environment Variables & PATH
# =============================================================================
export EDITOR=nvim
export VISUAL=$EDITOR

export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=1000

# User-local scripts
export PATH="$HOME/.bin:$PATH"

# =============================================================================
# Tool Initializations (Homebrew, asdf, direnv)
# =============================================================================
# --- Homebrew PATH Setup (macOS & Linux) ---
# Apple Silicon Mac
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
# Linux (or Intel Mac default)
elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- asdf (Language version manager) ---
# Homebrewでインストールされたasdfを読み込む (asdf.shが存在する場合のみ)
if [ -f "$(brew --prefix asdf 2>/dev/null)/libexec/asdf.sh" ]; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# --- direnv (Directory-based environment manager) ---
# direnv コマンドが存在する場合のみフックを有効化
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# =============================================================================
# Shell Options
# =============================================================================
setopt autocd
setopt EXTENDED_GLOB
unsetopt beep
bindkey -e

# =============================================================================
# Functions
# =============================================================================
# cd したら自動で eza を実行
function cdls() {
  builtin cd "$@" && eza --icons --group-directories-first
}

# rm コマンドを一時ディレクトリへの移動に置き換える
# 実行時の時刻を付加してファイル名の重複を回避
function saferm() {
    local tmp_dir="$HOME/.trash"
    mkdir -p "$tmp_dir"
    for file in "$@"; do
        if [ -e "$file" ]; then
            mv -i "$file" "$tmp_dir/$(basename "$file")_$(date +"%Y%m%d%H%M%S")"
        else
            echo "saferm: $file: No such file or directory"
        fi
    done
}
# =============================================================================
# Aliases
# =============================================================================
# General
alias src='source ~/.zshrc'
alias cl='clear'
alias ex='exit'

# Navigation & File Operations
alias cd="cdls"
alias rm="saferm"
alias mkdir="mkdir -p"
alias cp="cp -ip"
alias mv='mv -i'

# eza (ls replacement)
alias ls='eza --icons'
alias l='ls'
alias ll='eza -l -h --icons --git --group-directories-first'
alias la='eza -la --icons --git --group-directories-first'
alias lt='eza -T -L 2 -I "node_modules|.git|.cache"'

# Git & GitHub
alias g='git'
alias gs='git status'
alias ga='git add . && git status'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias t='tig'

# Development
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias cat='bat'

# Docker
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dps='docker ps'
alias dpsa='docker ps -a'

# =============================================================================
# Completions
# =============================================================================
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz compinit

# Add completions path if they exist
# asdf completions (if asdf was loaded)
if [ -n "$ASDF_DIR" ]; then
  fpath=(${ASDF_DIR}/completions $fpath)
fi

# docker completions (generic path)
if [ -d "${HOME}/.docker/completions" ]; then
  fpath=(${HOME}/.docker/completions $fpath)
fi

# Initialize completions system
zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"
compinit

# =============================================================================
# Powerlevel10k Prompt
# =============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
