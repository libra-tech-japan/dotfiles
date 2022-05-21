dotfiles
===============

Include a no plugin dotfiles.
Can be used quickly.

## HOWTO ##

### Prepear To Install
```
sudo apt update
sudo apt upgrade
```

# git setting
```
git config --global user.email "*******@example.com"
git config --global user.name "USER NAME"
git config --global core.editor 'vim -c "set fenc=utf-8"'  
git config --global color.diff auto 
git config --global color.status auto
git config --global color.branch auto
```


# GitHub connection setting
```
ssh-keygen
ssh -T git@github.com
```

# Add .gitconfig
```
[alias]
  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
  lga = log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
```

```
1. `git clone xxx`

2. `./bin/sh applnstall.sh

3. `./bin/dotsinstall.sh`

4. Create a new Zsh configuration by copying/linking the Zsh configuration files provided:

```
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

