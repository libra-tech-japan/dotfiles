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

# Homebrew (macOS & Linux)
# This handles setting the correct path for Homebrew on any system.
eval "$(brew shellenv)"

# asdf (Language version manager)
. "$(brew --prefix asdf)/libexec/asdf.sh"

# direnv (Directory-based environment manager)
eval "$(direnv hook zsh)"

# GHCup (Haskell)
[ -f "${HOME}/.ghcup/env" ] && source "${HOME}/.ghcup/env"

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
function cdls() {
  builtin cd "$@" && eza --icons
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
alias rm="rm -i" # safe-rm is not a default command, using standard -i
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
alias lg='lazygit'
alias gcd='cd $(ghq root)/$(ghq list | fzf)'

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
# Initializations
# =============================================================================
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Completions
autoload -Uz compinit

# Add asdf completions
fpath=(${ASDF_DIR}/completions $fpath)

# Add docker completions if they exist
if [ -d "${HOME}/.docker/completions" ]; then
  fpath=(${HOME}/.docker/completions/zsh $fpath)
fi

zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"
compinit

# Powerlevel10k Prompt
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
