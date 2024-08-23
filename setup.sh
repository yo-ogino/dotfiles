#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.zshrc $HOME/.zshrc
ln -s $DIR/.tmux.conf $HOME/.tmux.conf
ln -s $DIR/.gitconfig $HOME/.gitconfig
ln -s $DIR/Brewfile $HOME/Brewfile
ln -s $DIR/.aerospace.toml $HOME/.aerospace.toml
mkdir -p $HOME/.hammerspoon && ln -s $DIR/.hammerspoon/init.lua $HOME/.hammerspoon/init.lua
mkdir -p $HOME/.config/skhd && ln -s $DIR/.config/skhd/skhdrc $HOME/.config/skhd/skhdrc

[ ! -d $HOME/.warp ] && cp -r $DIR/.warp $HOME/.warp
