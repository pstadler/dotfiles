# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME=""

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

plugins=(z colored-man-pages history-substring-search fast-syntax-highlighting kubectl)

if type brew &>/dev/null; then
  FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
fi

[ -f ~/.env ] && source ~/.env

source $ZSH/oh-my-zsh.sh

export HISTSIZE=100000
export SAVEHIST=100000

zstyle ':completion:*' insert-tab false # don't write tabs to prompt

setopt hist_reduce_blanks # remove blanks for commands
setopt hist_ignore_all_dups # prevent duplicate entries
setopt interactive_comments # allow interactive comments
setopt transient_rprompt # only show rprompt on last line
unsetopt cdablevars # vars shouldn't expand to directory names

export LSCOLORS='ExFxCxDxbxegedabagacad'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# https://github.com/zdharma/fast-syntax-highlighting
FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}path]='fg=white,bold'
FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}path-to-dir]='fg=white,bold'
FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}global-alias]='fg=white,bold,bg=none'

eval "$(starship init zsh)"
