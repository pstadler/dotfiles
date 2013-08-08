export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export EDITOR=vim

export LESS='-IRX' # case insenstive search / raw color sequences / don't clear screen on exit
alias top='top -o cpu'
alias grep='grep --color'
alias duplicate='open -a Terminal .'

# homebrew
export PATH=/usr/local/homebrew/bin:/usr/local/homebrew/sbin:/usr/local/bin:$PATH
export MANPATH=/usr/local/homebrew/share/man:$MANPATH

# node.js
export NODE_PATH=/usr/local/homebrew/lib/node_modules
export PATH=$PATH:/usr/local/homebrew/share/npm/bin

export YUI_COMPRESSOR=/usr/local/homebrew/Cellar/yuicompressor/2.4.7/libexec/yuicompressor-2.4.7.jar
export NATURALDOCS_DIR=/usr/local/homebrew/Cellar/naturaldocs/1.52/libexec

# gettext
export PATH=/usr/local/homebrew/Cellar/gettext/0.18.1.1/bin:$PATH

# python
export PATH=/usr/local/homebrew/share/python:$PATH
export WORKON_HOME=$HOME/.virtualenvs
if [ -f /usr/local/homebrew/share/python/virtualenvwrapper.sh ]; then
	source /usr/local/homebrew/share/python/virtualenvwrapper.sh
fi

# go
export GOPATH=~/Go
export PATH=$PATH:$GOPATH/bin

# rvm
[[ -s "/Users/pstadler/.rvm/scripts/rvm" ]] && source "/Users/pstadler/.rvm/scripts/rvm"

# heroku toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# base64 encode
function base64 {
	openssl enc -base64 -in $1 |tr -d "\n"
}

# serve the current directory
function serve {
    port=${1:-8080}
    (ifconfig | grep -E 'inet.[0-9]' | grep -v -E '127.0.0.1|-->' | awk '{ printf $2}';echo ":$port") | pbcopy
    echo "URL copied to clipboard."
    python -m SimpleHTTPServer $port
}

# git commit stats by author
git-stats() {
	author=${1-`git config --get user.name`}

	echo "Commit stats for \033[1;37m$author\033[0m:"
	git log --shortstat --author $author -i 2> /dev/null \
		| grep -E 'files? changed' \
		| awk 'BEGIN{commits=0;inserted=0;deleted=0} \
			{commits+=1; if($5!~"^insertion") { deleted+=$4 } \
			else { inserted+=$4; deleted+=$6 } } END \
			{print "\033[1;34m↑↑\033[1;37m", commits \
			"\n\033[1;32m++\033[1;37m", inserted, \
			"\n\033[1;31m--\033[1;37m", deleted, "\033[0m"}'
}

# load host-specific shellrc
if [ -f ~/.bashrc_local ]; then
	source ~/.bashrc_local
fi
