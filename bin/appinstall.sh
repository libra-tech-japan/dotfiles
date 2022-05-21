#!/bin/bash

if [ "`uname`" == "Darwin" ]; then
  ISMAC=true
elif [ "`uname`" == "Linux" ]; then
  ISLINUX=true
fi

if [ $ISLINUX ]; then

	sudo apt-add-repository ppa:fish-shell/release-3 -y
	sudo apt update

	sudo apt install tree             -y
	sudo apt install ninja-build      -y
	sudo apt install gettext          -y
	sudo apt install libtool          -y
	sudo apt install libtool-bin      -y
	sudo apt install autoconf         -y
	sudo apt install automake         -y
	sudo apt install cmake            -y
	sudo apt install g++              -y
	sudo apt install pkg-config       -y
	sudo apt install unzip            -y
	sudo apt install curl             -y
	sudo apt install doxygen          -y
	sudo apt install tmux             -y
	sudo apt install fonts-powerline  -y
	sudo apt install python3-pip      -y
	sudo apt install ruby             -y 
	sudo apt install gem              -y
	sudo apt install ruby-dev         -y
	sudo apt install build-essential  -y
#	sudo apt install fish		  -y

	# Homebrew Install
	PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	sudo ln -s -f /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/
fi



brew install zsh
brew install --HEAD neovim
brew install --HEAD tree-sitter
brew install --HEAD luajit
brew install go
brew install rust
brew install exa
brew install bat
brew install ghq
brew install peco
brew install hub
brew install fzf
brew install anyenv
brew install zsh-syntax-highlighting

# CasheDirectory
CACHE=~/.cache
rm -rf $CACHE
mkdir $CACHE

#Install shell-safe-rm
SAFE_RM=$CACHE/shell-safe-rm
git clone https://github.com/kaelzhang/shell-safe-rm.git $SAFE_RM
sudo cp $SAFE_RM/bin/rm.sh /usr/local/bin/safe-rm
mkdir -p ~/.local/share/Trash/files
ln -s -f ~/.local/share/Trash/files ~/.trash

# Install oh-my-tmux
OH_MY_TMUX=$CACHE/oh-my-tmux
git clone https://github.com/gpakosz/.tmux.git $OH_MY_TMUX
ln -s -f $OH_MY_TMUX/.tmux.conf ~/.tmux.conf

# Install git-secrets
SECRET=$CACHE/git-secrets
git clone https://github.com/awslabs/git-secrets.git $SECRET
sudo chmod +x $SECRET/git-secrets
sudo cp $SECRET/git-secrets /usr/local/bin/
git secrets --register-aws --global
git secrets --install


# vim plugin maneger
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Install prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Install fisher
# curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish


