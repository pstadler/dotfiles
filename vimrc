" plugins
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'kien/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'ervandew/supertab'
Plug 'terryma/vim-multiple-cursors'
Plug 'matze/vim-move'
Plug 'scrooloose/nerdcommenter'
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/syntastic'
Plug 'w0ng/vim-hybrid'
Plug 'othree/yajs.vim'
Plug 'moll/vim-node'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-fugitive'
Plug 'editorconfig/editorconfig-vim'
"Plug 'nanotech/jellybeans.vim'
"Plug 'Lokaltog/vim-easymotion'

call plug#end()

" airline
set laststatus=2
set noshowmode
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='hybrid'

" gitgutter
set signcolumn=yes
set updatetime=750

" ctrlp
let g:ctrlp_custom_ignore = '\v[\/]\.(DS_Store|git|hg|svn)|node_modules$'
let g:ctrlp_show_hidden = 1

" move
let g:move_key_modifier = 'C'

" syntastic
"let g:syntastic_javascript_checkers = ['eslint']

" theme
syntax on
if !has("gui_running")
  "let g:solarized_termtrans=1
  let g:solarized_termcolors=256
endif
set background=dark
colorscheme hybrid
"hi LineNr ctermbg=NONE ctermfg=Black
"hi SignColumn ctermbg=NONE

" speed up
set ttyfast
set ttyscroll=3
" set lazyredraw

" config
let mapleader = ','

" buffers / files
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>q :bdelete<CR>
nnoremap <leader><leader> :w<CR>

" tabs / indent
set tabstop=2
set shiftwidth=2
set expandtab " spaces instead of tabs
set smartindent
set autoindent
set smarttab
" shift-tab to unindent
imap <S-Tab> <C-o><<

" no backups, swapfiles
set nobackup
set nowb
set noswapfile

" ruler, line numbers, cursorline
set ruler
set number
set textwidth=80
set colorcolumn=+0
set formatoptions-=t
" set cursorline " may slows things down dramatically
" hi clear CursorLine " don't highlight whole line as it's slow

" display command
"set showcmd

" allow opening buffers in background even if current is unsaved
set hidden

" disable folding
set nofoldenable

" search
set incsearch " find as you type
set smartcase
set nohlsearch

" keep lines when scrolling
set scrolloff=3

" if a file has been changed outside of vim and it has not been changed,
" automatically re-read it
set autoread

" macosx clipboard instead of vim's
set clipboard=unnamed

" delete to the left in insert mode with backspace
set backspace=indent,eol,start

" fix delete key in iTerm2
exe "set <Del>=\<Esc>[3;*~"

" remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
endif

" toggle insert mode
nnoremap <C-Y> i
imap <C-Y> <Esc>

" invisibles
"hi NonText ctermfg=Grey
"hi SpecialKey ctermfg=Grey
" shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
" use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" line numbers
nmap <leader>n :set number!<CR>

" line breaks
set showbreak=↳
" toggle showbreak
fun! ToggleShowBreak()
  if &showbreak == ''
    set showbreak=↳
  else
    set showbreak=
  endif
endfun
nmap <leader>b :call ToggleShowBreak()<CR>

" strip trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

