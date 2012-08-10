export CLICOLOR=1
export LSCOLORS='ExFxCxDxbxegedabagacad'

# command prompt
if [ `whoami` == "root" ]; then
    export PS1='\[\033[0;31m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
else
    export PS1='\[\033[0;32m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
fi

if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}
