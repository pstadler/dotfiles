# homebrew setup
export BREW_PREFIX=/usr/local/homebrew
export PATH=$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH
fpath=($BREW_PREFIX/share/zsh/site-functions $fpath)

# oh-my-zsh compat
export ZSH_CACHE_DIR=$HOME/Library/Caches/antibody/plugin_cache
[ ! -d $ZSH_CACHE_DIR ] && mkdir -p $ZSH_CACHE_DIR

source "/Users/pstadler/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

for file in ~/GitHub/dotfiles/zsh/*.zsh; do
  zpl ice lucid; zpl snippet $file
done

zpl ice wait"1" atinit"zpcompinit" lucid; zpl light zsh-users/zsh-completions
zpl ice wait"1" atinit"zpcompinit" lucid; zpl snippet https://github.com/docker/cli/raw/master/contrib/completion/zsh/_docker
zpl ice wait"1" lucid; zpl snippet OMZ::plugins/gnu-utils/gnu-utils.plugin.zsh
zpl ice wait"1" lucid; zpl snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zpl ice wait"1" pick"fasd" as"program" atload:'eval "$(fasd --init auto)"' lucid; zplugin light clvv/fasd
zpl ice wait"!1" atload"FAST_HIGHLIGHT_STYLES[path]='fg=white,bold';FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=white,bold'" lucid; zpl light zdharma/fast-syntax-highlighting
zpl ice wait"1" lucid; zpl light zsh-users/zsh-history-substring-search

for file in ~/GitHub/dotfiles/zsh/plugins/*.zsh; do
  zpl ice wait"1" lucid; zpl snippet $file
done



# Source env
[ -f ~/.env ] && source ~/.env
