call pathogen#infect()

set background=dark
syntax on
set tabstop=4
set shiftwidth=4
filetype plugin indent on

set smartindent
set autoindent
set smarttab
set noexpandtab " don't insert spaces for tabs

set nobackup
set nowb
set noswapfile

" show line numbers
set ruler
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" if a file has been changed outside of vim and it has not been changed,
" automatically re-read it
set autoread

" macosx clipboard instead of vim's
set clipboard=unnamed

" delete to the left in insert mode with backspace
set backspace=indent,eol,start

" NERDTree tabs
let g:nerdtree_tabs_synchronize_view = 1
let g:nerdtree_tabs_autoclose = 1
