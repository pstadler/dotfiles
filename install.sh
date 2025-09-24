#!/bin/sh

echo "Updating submodules..."
git submodule update --init --recursive

echo "Installing dotfiles..."
for symlink in zshrc bash_profile env gitconfig gitconfig-work gitignore \
                vim vimrc ackrc nvmrc hammerspoon tmux.conf alacritty.toml
do
  echo " symlink ~/.$symlink"
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

echo "Installing .config files..."
mkdir -p ~/.config
for symlink in starship.toml ghostty
do
  echo " symlink ~/.config/$symlink"
	rm ~/.config/$symlink
	ln -s $PWD/$symlink ~/.config/$symlink
done


echo "Installing ssh config..."
echo " symlink ~/.ssh/config"
rm ~/.ssh/config
ln -s $PWD/ssh/config ~/.ssh/config && chmod 0700 ~/.ssh/config
echo " mkdir   ~/.ssh/config.d/"
[ -d ~/.ssh/config.d ] || mkdir ~/.ssh/config.d && chmod -h 0700 ~/.ssh/config.d
echo " mkdir   ~/.ssh/sockets/"
[ -d ~/.ssh/sockets ] || mkdir ~/.ssh/sockets && chmod -h 0700 ~/.ssh/sockets

echo "Installing zsh plugins..."
ZSH_PLUGIN_DIR=~/.oh-my-zsh/custom/plugins
for symlink in $(ls zsh)
do
  echo " symlink $ZSH_PLUGIN_DIR/$symlink"
  [ -d $ZSH_PLUGIN_DIR/$symlink ] \
	  || ln -s $PWD/zsh/$symlink $ZSH_PLUGIN_DIR/$symlink
done