#!/bin/bash

for symlink in bash_profile bashrc gitconfig vim vimrc zshrc ackrc
do
	ln -s $PWD/$symlink ~/.$symlink
done

ln -s ~/GitHub/dotfiles/sublime-text-2/Packages/User ~/Library/Application\ Support/Sublime\ Text\ 2/Packages
