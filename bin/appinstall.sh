#!/bin/bash

if [ "`uname`" == "Darwin" ]; then
  ISMAC=true
elif [ "`uname`" == "Linux" ]; then
  ISLINUX=true
fi

#if [ $ISLINUX ]; then

	sudo apt update
  sudo apt install apt-transport-https -y
	sudo apt install manpages-ja      -y
	sudo apt install manpages-ja-dev  -y
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
	sudo apt install fonts-powerline  -y
	sudo apt install ruby             -y
	sudo apt install gem              -y
	sudo apt install ruby-dev         -y
	sudo apt install build-essential  -y

	# Homebrew Install
	PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	 sudo ln -s -f /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/
fi


brew update
brew install doxygen
brew install tmux
brew install tree
brew install zsh
brew install go
brew install jq
brew install rusut
brew install exa
brew install bat
brew install ghq
brew install hub
brew install fzf
brew install glow
brew install anyenv
brew install nodenv
brew install tig
brew install imagemagick
brew install deno
brew install lazygit
brew install neovim
brew install tree-sitter
brew install luajit

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

# CreateLocalBin
if [ ! -f $HOME/.local/bin ]; then
    mkdir -p  $HOME/.local/bin
fi

#tpx -- Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Docker for Linux
if [ $ISLINUX ]; then
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Install Docker
    sudo apt update
    sudo apt install docker-ce -y
    # Install Dockder-Compose
    mkdir -p ~/.docker/cli-plugins/
    sudo curl -L https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-`uname -s`-`uname -m` -o ~/.docker/cli-plugins/docker-compose
    sudo chmod +x ~/.docker/cli-plugins/docker-compose
    sudo usermod -aG docker $USER
fi
