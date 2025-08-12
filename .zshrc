# =============================================================================
# Powerlevel10k Instant Prompt
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Prezto
# =============================================================================
# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# =============================================================================
# Environment Variables
# =============================================================================
export EDITOR=nvim
export VISUAL=$EDITOR

export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=1000

# PATH adjustments
export PATH="$PATH:$HOME/.bin"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - )"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# GHCup
[ -f "/Users/akira/.ghcup/env" ] && source "/Users/akira/.ghcup/env" # ghcup-env

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
    # Use `command cd` to avoid alias loop
    command cd "$@"
    if [ "$?" -eq 0 ]; then
        eza --icons
    fi
}

# =============================================================================
# Aliases
# =============================================================================
# General
alias src='source ~/.zshrc'
alias cl='clear'
alias ex='exit'
alias jutf='export LANG=ja_JP.UTF-8'
alias jeuc='export LANG=ja_JP.euc-jp'

# Navigation & File Operations
alias cd="cdls"
alias rm="safe-rm"
alias mkdir="mkdir -p"
alias Trash="~/.trash"
alias cp="cp -ip"
alias mv='mv -i'
alias scp="scp -p"
alias findall="find / -type d -name 'mnt' -prune -o "

# eza (ls replacement)
alias e='eza --icons'
alias l='e'
alias ls='e'
alias ee='eza -l -h -@ -m --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias ll='ee'
alias ea='eza -l -aa -h -@ -m --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias lla='ea'
alias et='eza -T -L 3 -a -I "node_modules|.git|.cache" --icons'
alias lt='et'
alias eta='eza -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
alias lta='eta'

# Git
alias g='git'
alias gs='git status'
alias ga='git add . && git status'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias t='tig'
alias tg='tig'
alias lg='lazygit'

# GitHub
alias hb='hub browse'
alias hbrl='hub browse $(ghq list | fzf | cut -d "/" -f 2,3)'
alias gcd='cd $(ghq root)/$(ghq list | fzf)'

# Development
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias cat='bat'
alias dt='dotnet'
alias tsinit='npm init --yes && npm install -D typescript eslint @types/node && ./node_modules/.bin/tsc --init --outDir "dist"  && ./node_modules/.bin/eslint --init'

# Docker
alias dcu='docker-compose up -d '
alias dcd='docker-compose down '

# =============================================================================
# Initializations
# =============================================================================
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Completions
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/akira/.zshrc'
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/akira/.docker/completions $fpath)
autoload -Uz compinit
compinit

# Powerlevel10k Prompt
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
autoload -Uz promptinit
promptinit
prompt powerlevel10k