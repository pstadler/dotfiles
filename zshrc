# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="lukerandall"

# Set to this to use case-sensitive completion
CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
#DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git brew heroku rails3 django zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
unsetopt correct_all
zstyle ':completion:*' insert-tab false
PROMPT='%{$fg_bold[green]%}%n%{$fg_bold[white]%}@%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$reset_color%} $(my_git_prompt_info)%{$reset_color%}%B»%b '
export LSCOLORS='ExFxCxDxbxegedabagacad'
ZSH_HIGHLIGHT_STYLES[path]='fg=white,bold'

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
