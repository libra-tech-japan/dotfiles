# dotfiles

===============

Include a no plugin dotfiles.
Can be used quickly.

## HOWTO

### Prepare To Install

```bash
sudo apt update -y && sudo apt upgrade -y
```

## Git setting

create `~/.gitconfig.local` file

```toml
[user]
  email=xxx@example.com
  name=username
```

## GitHub connection setting

```bash
ssh-keygen
# Copy .ssh/id_rsa.pub to Github
ssh -T git@github.com
```

## Clone & Install

```bash
1. `git clone xxx`
2. `/bin/sh install.sh

```

## Create a new Zsh configuration by copying/linking the Zsh configuration files provided

```bash
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

## prezto is PowerLevel10k

`p10k configure`

# After node.js Installed

## commitizen install

```npm
npm install commitizen -g
npm install -g cz-conventional-changelog
npm install -g cz-conventional-changelog-ja
```

<https://github.com/commitizen/cz-cli>
