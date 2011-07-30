# enable colors
export CLICOLOR=1
export LSCOLORS='ExFxCxDxbxegedabagacad'

# command prompt
if [ `whoami` == "root" ]; then
	export PS1='\[\033[0;31m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
else
	export PS1='\[\033[0;32m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
fi

# aliases
alias top='top -o cpu'

# path
export PATH=/usr/local/homebrew/bin:/usr/local/homebrew/sbin:/usr/local/homebrew/Cellar/ruby/1.9.2-p180/bin:/usr/local/bin:$PATH
export MANPATH=/usr/local/homebrew/share/man:$MANPATH

# load host-specific bashrc
if [ -f ~/.bashrc_local ]; then
	source ~/.bashrc_local
fi
