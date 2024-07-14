#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.zshrc $HOME/.zshrc
#ln -s $DIR/.gvimrc $HOME/.gvimrc
ln -s $DIR/.tmux.conf $HOME/.tmux.conf
ln -s $DIR/.gitconfig $HOME/.gitconfig
ln -s $DIR/Brewfile $HOME/Brewfile

# todo aerospaceとhammerspoonのinitをlnする

#git clone --recursive https://github.com/yo-ogino/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

#sudo cp tmuxx /usr/local/bin/

#if [ `uname` = "Darwin" ]; then
#  sudo cp tmux-pbcopy /usr/local/bin/
#elif [ `uname` = "Linux" ]; then
#  sudo cp tmux-pbcopy_ubuntu /usr/local/bin/
#fi
