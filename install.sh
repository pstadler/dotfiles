#!/bin/bash

# Install dotfiles
for symlink in bash_profile bashrc gitconfig vim vimrc zshrc ackrc slate
do
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

# Install virtualenv hooks
for symlink in postactivate postdeactivate
do
	rm ~/.virtualenvs/$symlink
	ln -s $PWD/virtualenvs/$symlink ~/.virtualenvs
done

# Sublime Text 2 Config and symlink
cd 
find ~/GitHub/dotfiles/sublime-text-2/Packages/User/* | while read FILE
do
	ln -s "$FILE" ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User
done
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
