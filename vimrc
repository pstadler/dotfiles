let mapleader = ','

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
"set number
hi LineNr cterm=NONE ctermfg=DarkGrey ctermbg=Black

" display command
set showcmd

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

" remember last location in file
if has("autocmd")
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
endif

" status line
set laststatus=2
set title
"set statusline+=%{fugitive#statusline()} " add current branch to statusline
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
hi StatusLine ctermfg=Grey ctermbg=Black
hi StatusLineNC ctermfg=DarkGrey ctermbg=Black
au InsertEnter * hi StatusLine ctermfg=Blue ctermbg=Black
au InsertLeave * hi StatusLine ctermfg=Grey ctermbg=Black

"
" Syntastic
"
let g:syntastic_enable_signs=0

"
" Tabs (MiniBufExplorer)
"
function! MiniBufExplorer()
	if bufname("%") == '-MiniBufExplorer-'
		exec "normal \<cr>"
	else
		MiniBufExplorer
	endif
endfunction
" 167 = §
nmap <Char-167> :call MiniBufExplorer()<CR>
nmap <S-Tab> :bp<CR>
nmap <Tab> :bn<CR>

"
" Toggle insert mode
"
nnoremap <C-Y> i
imap <C-Y> <Esc>

"
" Command-T
"
function! CommandT()
	if bufname("%") == '-MiniBufExplorer-'
		exec "normal! \<c-w>\<c-w>"
	endif
	CommandTFlush
	CommandT
endfunction
map <C-X> :call CommandT()<CR>

"
" Invisibles
"
hi NonText ctermfg=DarkGrey
hi SpecialKey ctermfg=DarkGrey
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
