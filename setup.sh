#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.zshrc $HOME/.zshrc
ln -s $DIR/.tmux.conf $HOME/.tmux.conf
ln -s $DIR/.gitconfig $HOME/.gitconfig
ln -s $DIR/Brewfile $HOME/Brewfile
ln -s $DIR/.aerospace $HOME/.aerospace
mkdir -p $HOME/.hammerspoon && ln -s $DIR/.hammerspoon/init.lua $HOME/.hammerspoon/init.lua

[ ! -d $HOME/.warp ] && cp -r $DIR/.warp $HOME/.warp
