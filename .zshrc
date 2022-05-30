# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/akira/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export EDITOR=nvim
export VISUAL=$EDITOR


############################
### Function definitions ###
############################
function cdls() {
    # cdがaliasでループするので\をつける
    \cd "$@";
    if [ "$?" -eq 0 ];then
        exa --icons
    fi
}


#############
### Alias ###
#############
alias src='source ~/.zshrc'

alias cd="cdls"

alias ls='ls --color=auto'
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -al'
alias lal='ls -al'

alias cl='clear'
alias rm="safe-rm"
alias mkdir="mkdir -p"
alias Trash="~/.trash"
alias cp="cp -ip"
alias mv='mv -i'
alias scp="scp -p"
alias sc="screen"
alias gre="grep --color=auto -n -H -i -I"
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias ex='exit'
alias jutf='export LANG=ja_JP.UTF-8'
alias jeuc='export LANG=ja_JP.euc-jp'
alias findall="find / -type d -name 'mnt' -prune -o "

alias tsinit='npm init --yes && npm install -D typescript eslint @types/node && ./node_modules/.bin/tsc --init && ./node_modules/.bin/eslint --init'

alias e='exa --icons'
alias l=e
alias ls=e

alias ee='exa -l -h -@ -m --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias ll=ee

alias ea='exa -l -aa -h -@ -m --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias lla=ea

alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
alias lt=et
alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
alias lta=eta

alias g='git'
alias gs='git status'
alias ga='git add . && git status '
alias t='tig'
alias tg=t

alias cat='bat'

# 現在の作業リポジトリをブラウザで表示する
alias hb='hub browse'
# リポジトリの一覧の中からブラウザで表示したい対象を検索・表示する
alias hbrl='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
# リポジトリのディレクトリへ移動
alias gcd='cd $(ghq root)/$(ghq list | peco)'

###############################
## 初回シェル時のみ tmux実行
###############################
#alias tmux="tmux -u2"
#
## tmuxの自動起動
#count=`ps aux | grep tmux | grep -v grep | wc -l`
#if test $count -eq 0; then
#    echo `tmux`
#elif test $count -eq 1; then
#    echo `tmux a`
#fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
autoload -Uz promptinit
promptinit
prompt powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

##############################
# Path
##############################
export PATH="$PATH:$HOME/.bin"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"


# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - )"

# nodenv
export NODENV_ROOT="$HOME/.nodenv"
export PATH="$NODENV_ROOT/bin:$PATH"
eval "$(nodenv init - )"
