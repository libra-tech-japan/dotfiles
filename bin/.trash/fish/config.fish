if status is-interactive
    # Commands to run in interactive sessions can go here
end


#############
### Alias ###
#############
alias ls='ls --color=auto'
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -al'
alias lal='ls -al'
alias cl='clear'
alias rm="safe-rm"
alias Trash="~/.trash"
alias cp="cp -ip"
alias mv='mv -i'
alias scp="scp -p"
alias sc="screen"
alias gre="grep --color=auto -n -H -i -I"
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias jutf='export LANG=ja_JP.UTF-8'
alias jeuc='export LANG=ja_JP.euc-jp'
alias findall="find / -type d -name 'mnt' -prune -o "

alias e='exa --icons'
alias l=e
alias ls=e
alias ea='exa -a --icons'
alias la=ea
alias ee='exa -aal --icons'
alias ll=ee
alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
alias lt=et
alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
alias lta=eta

alias g='git'
alias cat='bat'

status --is-interactive; and source (nodenv init -|psub)

