#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.zshrc $HOME/.zshrc
ln -s $DIR/.gvimrc $HOME/.gvimrc
ln -s $DIR/.tmux.conf $HOME/.tmux.conf

#rm $HOME/.gitconfig
#cp $DIR/.gitconfig $HOME/.gitconfig

#git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

sudo cp tmuxx /usr/local/bin/

if [ `uname` = "Darwin" ]; then
  sudo cp tmux-pbcopy /usr/local/bin/
elif [ `uname` = "Linux" ]; then
  sudo cp tmux-pbcopy_ubuntu /usr/local/bin/
fi
