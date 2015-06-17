#!/bin/sh

echo "Installing dotfiles:"
for symlink in zshrc bash_profile env env_chpwd gitconfig \
                vim vimrc ackrc nvmrc ruby-version zephyros.rb
do
  echo " symlink: ~/.$symlink"
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

echo "Installing ST3 config and cli:"
find $PWD/sublime-text-3/Packages/User/* -depth 0 | while read FILE
do
  echo " symlink: $(basename "$FILE")"
  ln -s "$FILE" ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
done

echo " symlink: /usr/local/bin/subl"
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

# Install virtualenv hooks
#for symlink in postactivate postdeactivate
#do
#	rm ~/.virtualenvs/$symlink
#	ln -s $PWD/virtualenvs/$symlink ~/.virtualenvs
#done

# Apache2
#sudo ln -s $PWD/apache2/pstadler.conf /etc/apache2/users
#sudo ln -s $PWD/apache2/pow.conf /etc/apache2/other
#echo 8080 > ~/.pow/apache
#sudo apachectl graceful
