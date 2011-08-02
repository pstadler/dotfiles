export CLICOLOR=1
export LSCOLORS='ExFxCxDxbxegedabagacad'

export EDITOR=vim

# command prompt
if [ `whoami` == "root" ]; then
	export PS1='\[\033[0;31m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
else
	export PS1='\[\033[0;32m\]\u\[\033[0;37m\]@\[\033[0;37m\]\h \[\033[1;34m\]\w \[\033[0;37m\]\$ '
fi

alias top='top -o cpu'
alias less='less -I'
alias grep='grep --color'

export PATH=/usr/local/homebrew/bin:/usr/local/homebrew/sbin:/usr/local/homebrew/Cellar/ruby/1.9.2-p180/bin:/usr/local/bin:$PATH
export MANPATH=/usr/local/homebrew/share/man:$MANPATH

export YUI_COMPRESSOR=/usr/local/homebrew/Cellar/yuicompressor/2.4.6/libexec/yuicompressor-2.4.6.jar
export NATURALDOCS_DIR=/usr/local/homebrew/Cellar/naturaldocs/1.52/libexec

# base64 encode
function base64 {
	openssl enc -base64 -in $1 |tr -d "\n"
}

# serve the current directory
function share {
    port=${1:-8080}
    (ifconfig | grep -E 'inet.[0-9]' | grep -v -E '127.0.0.1|-->' | awk '{ printf $2}';echo ":$port") | pbcopy
    echo "Share link copied to clipboard."
    python -m SimpleHTTPServer $port
}

# load host-specific bashrc
if [ -f ~/.bashrc_local ]; then
	source ~/.bashrc_local
fi
