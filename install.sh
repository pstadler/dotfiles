#!/bin/bash

for symlink in bash_profile bashrc gitconfig vim vimrc zshrc ackrc
do
	ln -s $PWD/$symlink ~/.$symlink
done
