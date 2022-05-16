dotfiles mini
===============

Include a no plugin dotfiles.
Can be used quickly.

## HOWTO ##

### Prepear To Install

sudo apt update
sudo apt upgrade

# git setting
git config --global user.email "*******@example.com"
git config --global user.name "USER NAME"
git config --global core.editor 'vim -c "set fenc=utf-8"'  
git config --global color.diff auto 
git config --global color.status auto
git config --global color.branch auto


[alias]
  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
  lga = log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative

# GitHub connection settiong
ssh-keygen
ssh -T git@github.com


1. `git clone xxx`

2. `./bin/sh applnstall.sh

3. `./bin/dotsinstall.sh`

4. fish Plugin
`fisher install jethrokuan/z`
`fisher install oh-my-fish/theme-bobthefish4. fish Plugin`

