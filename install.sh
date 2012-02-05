#!/bin/bash

# Install dotfiles
for symlink in bash_profile bashrc gitconfig vim vimrc zshrc ackrc
do
	ln -s $PWD/$symlink ~/.$symlink
done

# Sublime Text 2 Config and symlink
cd 
find ~/GitHub/dotfiles/sublime-text-2/Packages/User/* | while read FILE
do
	ln -s "$FILE" ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User
done
ln -s /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
