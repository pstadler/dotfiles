" plugins
call plug#begin('~/.vim/plugged')

Plug 'bling/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'

call plug#end()

" airline
set laststatus=2
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#tabline#enabled = 1

" gitgutter
let g:gitgutter_override_sign_column_highlight = 0

" theme
syntax on
if !has("gui_running")
	let g:solarized_termtrans=1
	"let g:solarized_termcolors=256
endif
set background=light
colorscheme solarized
"hi LineNr ctermbg=NONE ctermfg=Black
hi SignColumn ctermbg=NONE

" config
let mapleader = ','

" buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>q :bdelete<CR>

" tabs
set tabstop=2
set shiftwidth=2

" indent
set smartindent
set autoindent
set smarttab

" no backups, swapfiles
set nobackup
set nowb
set noswapfile

" show ruler, line numbers
set ruler
set number

" display command
"set showcmd

" allow opening buffers in background even if current is unsaved
set hidden

" disable folding
set nofoldenable

"search
set incsearch " find as you type
set smartcase
"set hlsearch

" if a file has been changed outside of vim and it has not been changed,
" automatically re-read it
set autoread

" macosx clipboard instead of vim's
" set clipboard=unnamed

" delete to the left in insert mode with backspace
set backspace=indent,eol,start

" fix delete key in iTerm2
exe "set <Del>=\<Esc>[3;*~"

" remember last location in file
if has("autocmd")
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
endif

"
" Toggle insert mode
"
nnoremap <C-Y> i
imap <C-Y> <Esc>

"
" Invisibles
"
hi NonText ctermfg=Grey
hi SpecialKey ctermfg=Grey
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

"
" Line Numbers
"
nmap <leader>n :set number!<CR>

"
" Linebreaks
"
set showbreak=↳\
" Toggle showbreak
function! ToggleShowBreak()
	if &showbreak == ''
		set showbreak=↳\
	else
		set showbreak=
	endif
endfunction
nmap <leader>b :call ToggleShowBreak()<CR>
