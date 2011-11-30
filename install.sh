#!/bin/bash

for symlink in bash_profile bashrc gitconfig vim vimrc zshrc
do
	ln -s $PWD.$symlink ~/test/.$symlink
done
