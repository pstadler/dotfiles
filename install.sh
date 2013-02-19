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

# Sublime Text 3 config symlinks
cd
find ~/GitHub/dotfiles/sublime-text-3/Packages/User/* | while read FILE
do
	ln -s "$FILE" ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
done
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
