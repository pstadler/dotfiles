# Path to your oh-my-zsh configuration.
# ZSH=$HOME/.oh-my-zsh
source ~/.zplug/init.zsh

# completions
zplug "zsh-users/zsh-completions"
zplug "lib/completion", from:oh-my-zsh
zplug "lib/compfix", from:oh-my-zsh
zplug "lukechilds/zsh-better-npm-completion"

# utils
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "agkozak/zsh-z"
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "${0:a:h}/zsh/kubectl", from:local

zplug check || zplug install

if type brew &>/dev/null; then
  FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
fi

zplug load

if zplug check "zdharma/fast-syntax-highlighting"; then
  FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}path]='fg=white,bold'
  FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}path-to-dir]='fg=white,bold'
  FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}global-alias]='fg=white,bold,bg=none'
fi

if zplug check "zsh-users/zsh-history-substring-search"; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# history
export HISTSIZE=100000
export SAVEHIST=100000
setopt hist_reduce_blanks     # remove blanks for commands
setopt hist_ignore_all_dups   # prevent duplicate entries
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

export CLICOLOR=1
export LSCOLORS='ExFxCxDxbxegedabagacad'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # inherit ls colors
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*' # case-insensitive lists, dirs, etc.
zstyle ':completion:*' insert-tab false # don't write tabs to prompt
zstyle ':completion:::::default' menu yes select #  don't ask about showing large lists
# zstyle ':autocomplete:*' insert-unambiguous yes # don't select first result

setopt auto_cd
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

unsetopt cdablevars # vars shouldn't expand to directory names
setopt interactive_comments # allow interactive comments

bindkey -v # Use vim key bindings
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
# file rename magick
bindkey "^[m" copy-prev-shell-word
# history expansion
bindkey ' ' magic-space

bindkey '^r' history-incremental-search-backward

zmodload zsh/terminfo
if [ -n "${terminfo[kcuu1]}" ]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search # start typing + [Up-Arrow] - fuzzy find history forward
fi
if [ -n "${terminfo[kcud1]}" ]; then
  bindkey "${terminfo[kcud1]}" down-line-or-search # start typing + [Down-Arrow] - fuzzy find history backward
fi

[ -f ~/.env ] && source ~/.env

eval "$(starship init zsh)"
