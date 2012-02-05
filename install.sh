#!/bin/bash

# Install dotfiles
for symlink in bash_profile bashrc gitconfig vim vimrc zshrc ackrc
do
	ln -s $PWD/$symlink ~/.$symlink
done

# Sublime Text 2 Config and symlink
ln -s ~/GitHub/dotfiles/sublime-text-2/Packages/User ~/Library/Application\ Support/Sublime\ Text\ 2/Packages
ln -s /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
