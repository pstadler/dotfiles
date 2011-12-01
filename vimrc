call pathogen#infect()

syntax on
set background=dark

filetype plugin indent on

" tabs 
set tabstop=4
set shiftwidth=4

" indent
set smartindent
set autoindent
set smarttab
set noexpandtab " don't insert spaces for tabs

" no backups, swapfiles
set nobackup
set nowb
set noswapfile

" show ruler, line numbers
set ruler
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"search
set incsearch " find as you type
set smartcase
set hlsearch

" if a file has been changed outside of vim and it has not been changed,
" automatically re-read it
set autoread

" macosx clipboard instead of vim's
set clipboard=unnamed

" delete to the left in insert mode with backspace
set backspace=indent,eol,start

" remember last location in file
if has("autocmd")
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
endif

" NERDTree tabs
let g:nerdtree_tabs_synchronize_view = 1
let g:nerdtree_tabs_autoclose = 1
