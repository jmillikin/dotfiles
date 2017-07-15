set nocompatible
set backspace=indent,eol,start

syntax on
filetype plugin indent on

set tabstop=4 shiftwidth=4

" Line numbers
set number

" Enable folding
set foldenable
set foldmethod=marker

" Block indenting
map < <gv
map > >gv

set encoding=utf-8

" Switching away from modified buffers
set hidden

" Incremental search. n: forward, N: backward
set incsearch
set hlsearch

" Smart search casing
set ignorecase
set smartcase

set list
set listchars=tab:»»,trail:·

set ai

" sort *.pyc below *.py
let netrw_sort_sequence='[\/]$,\.[a-np-z]$,\.h$,\.c$,\.cpp$,*,\.pyc$,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$'
set ruler

set laststatus=2
set scs

" File navigation
let NERDTreeChDirMode = 2
let NERDTreeShowBookmarks = 1

" F9 opens file explorer
nnoremap <silent> <F9> :NERDTreeToggle<CR>

if has("gui_running")
	set gfn=Inconsolata\ Medium\ 12
	
	" Darker color scheme
	" colorscheme zenburn
endif

set background=dark
