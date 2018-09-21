#!/bin/sh

echo "Installing dotfiles:"
for symlink in zshrc bash_profile env env_chpwd gitconfig gitignore \
                vim vimrc ackrc nvmrc hammerspoon tmux.conf alacritty.yml
do
  echo " symlink: ~/.$symlink"
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

echo "Installing zsh plugins..."
ZSH_PLUGIN_DIR=~/.oh-my-zsh/custom/plugins
[ -d $ZSH_PLUGIN_DIR/kubectl ] \
  || ln -s $PWD/zsh/kubectl $ZSH_PLUGIN_DIR/kubectl
[ -d $ZSH_PLUGIN_DIR/zsh-syntax-highlighting ] \
  || git clone git@github.com:zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGIN_DIR/zsh-syntax-highlighting
[ -d $ZSH_PLUGIN_DIR/zsh-nvm ] \
  || git clone git@github.com:lukechilds/zsh-nvm.git $ZSH_PLUGIN_DIR/zsh-nvm
echo "done"
