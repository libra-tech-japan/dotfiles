# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

####################
### Color Define ###
####################
# Reset
Color_Off="\033[0m"       # Text Reset

# Regular Colors
Black="\033[0;30m"        # Black
Red="\033[0;31m"          # Red
Green="\033[0;32m"        # Green
Yellow="\033[0;33m"       # Yellow
Blue="\033[0;34m"         # Blue
Purple="\033[0;35m"       # Purple
Cyan="\033[0;36m"         # Cyan
White="\033[0;37m"        # White

# Bold
BBlack="\033[1;30m"       # Black
BRed="\033[1;31m"         # Red
BGreen="\033[1;32m"       # Green
BYellow="\033[1;33m"      # Yellow
BBlue="\033[1;34m"        # Blue
BPurple="\033[1;35m"      # Purple
BCyan="\033[1;36m"        # Cyan
BWhite="\033[1;37m"       # White

# Underline
UBlack="\033[4;30m"       # Black
URed="\033[4;31m"         # Red
UGreen="\033[4;32m"       # Green
UYellow="\033[4;33m"      # Yellow
UBlue="\033[4;34m"        # Blue
UPurple="\033[4;35m"      # Purple
UCyan="\033[4;36m"        # Cyan
UWhite="\033[4;37m"       # White

# Background
On_Black="\033[40m"       # Black
On_Red="\033[41m"         # Red
On_Green="\033[42m"       # Green
On_Yellow="\033[43m"      # Yellow
On_Blue="\033[44m"        # Blue
On_Purple="\033[45m"      # Purple
On_Cyan="\033[46m"        # Cyan
On_White="\033[47m"       # White

# High Intensty
IBlack="\033[0;90m"       # Black
IRed="\033[0;91m"         # Red
IGreen="\033[0;92m"       # Green
IYellow="\033[0;93m"      # Yellow
IBlue="\033[0;94m"        # Blue
IPurple="\033[0;95m"      # Purple
ICyan="\033[0;96m"        # Cyan
IWhite="\033[0;97m"       # White

# Bold High Intensty
BIBlack="\033[1;90m"      # Black
BIRed="\033[1;91m"        # Red
BIGreen="\033[1;92m"      # Green
BIYellow="\033[1;93m"     # Yellow
BIBlue="\033[1;94m"       # Blue
BIPurple="\033[1;95m"     # Purple
BICyan="\033[1;96m"       # Cyan
BIWhite="\033[1;97m"      # White

# High Intensty backgrounds
On_IBlack="\033[0;100m"   # Black
On_IRed="\033[0;101m"     # Red
On_IGreen="\033[0;102m"   # Green
On_IYellow="\033[0;103m"  # Yellow
On_IBlue="\033[0;104m"    # Blue
On_IPurple="\033[10;95m"  # Purple
On_ICyan="\033[0;106m"    # Cyan
On_IWhite="\033[0;107m"   # White

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

##############
### Custom ###
##############
ulimit -c 10000000
# 履歴のサイズ。
HISTSIZE=50000
HISTFILESIZE=50000

# 履歴ファイルを上書きではなく追加する。
# 複数のホストで同時にログインすることがあるので、上書きすると危険だ。
shopt -s histappend
# "!"をつかって履歴上のコマンドを実行するとき、
# 実行するまえに必ず展開結果を確認できるようにする。
shopt -s histverify
# 履歴の置換に失敗したときやり直せるようにする。
shopt -s histreedit
# 端末の画面サイズを自動認識。
shopt -s checkwinsize
# "@" のあとにホスト名を補完させない。
shopt -u hostcomplete
# つねにパス名のテーブルをチェックする。
shopt -s checkhash
# 変数を展開する
shopt -s cdable_vars
# なにも入力してないときはコマンド名を補完しない。
# (メチャクチャ候補が多いので。)
shopt -s no_empty_cmd_completion
export HISTCONTROL=ignoreboth
export HISTIGNORE=cd:history:ls:which   #you can use wild cart(*,?)
# Ctrl-dでログアウトしない
set -o ignoreeof
# GUIで認証しない
unset SSH_ASKPASS
# lessでカラー表示
export LESS='--no-init -R --shift 4 --LONG-PROMPT --quit-if-one-screen'

# ターミナル使用時の設定 #
case "$TERM" in
  kterm|*xterm*|sun|screen*)
    # stty
    stty erase '^H'
    stty erase '^?'
    stty werase '^W'
    stty stop undef
    # word delete
    stty werase undef
    if [[ "$-" =~ "i" ]]; then
        # 隠しファイルを補完候補に入れない
        bind 'set match-hidden-files off'
        bind '\C-w:unix-filename-rubout'
    fi
    _termtitle="\h:\w"
    ;;
esac

################
### Complete ###
################
complete -d cd
complete -c man
complete -c h
complete -c wi
complete -v unset

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
alias cd="cdls"
alias gre="grep --color=auto -n -H -i -I"
# alias makecolor="makecolor"
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

# 現在の作業リポジトリをブラウザで表示する
alias hb='hub browse'
# リポジトリの一覧の中からブラウザで表示したい対象を検索・表示する
alias hbrl='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
# リポジトリのディレクトリへ移動
alias gcd='cd $(ghq root)/$(ghq list | peco)'


##########################
## load local settings ###
##########################
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

##############################
# 初回シェル時のみ tmux実行
##############################
alias tmux="tmux -u2"

# tmuxの自動起動
count=`ps aux | grep tmux | grep -v grep | wc -l`
if test $count -eq 0; then
    echo `tmux`
elif test $count -eq 1; then
    echo `tmux a`
fi

# anyenv設定
eval "$(anyenv init -)"

# nodenv設定
eval "$(nodenv init -)"

##############
### Export ###
##############
export PATH="$PATH:$HOME/.bin"

if [ -f /usr/local/bin/nvim ]; then
    export EDITOR=/usr/local/bin/nvim
fi

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"


############################
### fish shell   
############################
exec fish

