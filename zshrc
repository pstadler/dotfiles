source ~/GitHub/dotfiles/zsh/opts.zsh
source ~/GitHub/dotfiles/zsh/keys.zsh
source ~/GitHub/dotfiles/zsh/theme.zsh

# History
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi
HISTSIZE=10000
SAVEHIST=10000

# Load and run compinit
autoload -U compinit
compinit -i -d "${ZSH_COMPDUMP}"

# Autocompletion
WORDCHARS=''
zmodload -i zsh/complist
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # case insensitive autocompletion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01' # process list style
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w" # disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
cdpath=(.)

# Enable caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH/cache/

# Discard tabs written to prompt
zstyle ':completion:*' insert-tab false

# Smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# Plugins
source .zsh-antigen/antigen.zsh

antigen bundle zsh-users/zsh-completions src

antigen bundle zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[path]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_approx]='fg=none'

antigen apply

# Source env
[ -f ~/.env ] && source ~/.env