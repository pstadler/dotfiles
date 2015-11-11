# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="lukerandall"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

plugins=(fasd git git-flow brew brew-cask rbenv npm gem pip heroku bundler bower \
          aws docker gnu-utils colored-man zsh-syntax-highlighting vagrant composer)

[ -f ~/.env ] && source ~/.env

source $ZSH/oh-my-zsh.sh

zstyle ':completion:*' insert-tab false # don't write tabs to prompt

setopt hist_reduce_blanks # remove blanks for commands
setopt interactive_comments # allow interactive comments
unsetopt cdablevars # vars shouldn't expand to directory names

PROMPT='%{$fg_bold[blue]%}%~%{$reset_color%} $(my_git_prompt_info)%{$reset_color%}%B»%b '
ZSH_HIGHLIGHT_STYLES[path]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_approx]='fg=none'

export LSCOLORS='ExFxCxDxbxegedabagacad'

zstyle ":chpwd:profiles:${HOME}/GitHub(|/|/*)" profile private
zstyle ":chpwd:profiles:${HOME}/Work(|/|/*)" profile work
[ -f ~/.env_chpwd ] && source ~/.env_chpwd
