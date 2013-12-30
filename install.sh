#!/bin/bash

# Install dotfiles
for symlink in zshrc bash_profile env gitconfig vim vimrc ackrc ruby-version zephyros.rb
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
find $PWD/sublime-text-3/Packages/User/* -depth 0 | while read FILE
do
	ln -s "$FILE" ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
done
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

# Apache2
sudo ln -s $PWD/apache2/pstadler.conf /etc/apache2/users
sudo ln -s $PWD/apache2/pow.conf /etc/apache2/other
echo 8080 > ~/.pow/apache
sudo apachectl graceful
