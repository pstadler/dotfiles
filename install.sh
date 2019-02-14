#!/bin/sh

echo "Installing dotfiles..."
for symlink in zshrc bash_profile env env_chpwd gitconfig gitignore \
                vim vimrc ackrc nvmrc hammerspoon tmux.conf alacritty.yml
do
  echo " symlink ~/.$symlink"
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
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
echo " symlink $ZSH_PLUGIN_DIR/kubectl"
[ -d $ZSH_PLUGIN_DIR/kubectl ] \
  || ln -s $PWD/zsh/kubectl $ZSH_PLUGIN_DIR/kubectl
echo " install $ZSH_PLUGIN_DIR/fast-syntax-highlighting"
[ -d $ZSH_PLUGIN_DIR/fast-syntax-highlighting ] \
  || git clone git@github.com:zdharma/fast-syntax-highlighting.git $ZSH_PLUGIN_DIR/fast-syntax-highlighting
echo " install $ZSH_PLUGIN_DIR/zsh-nvm"
[ -d $ZSH_PLUGIN_DIR/zsh-nvm ] \
  || git clone git@github.com:lukechilds/zsh-nvm.git $ZSH_PLUGIN_DIR/zsh-nvm
