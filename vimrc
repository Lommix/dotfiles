" quick remote config
"
set nocompatible
filetype off
filetype plugin indent on
syntax on
set shiftwidth=4
set number
set ruler
set visualbell
set encoding=utf-8
set modelines=0
set colorcolumn=80
set wrap
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set tabstop=2 shiftwidth=2 expandtab
set wildmenu
set wildmode=list:longest
set hidden
set ttyfast
set laststatus=2
set showmode
set showcmd


let mapleader = " "
:map <leader>e :Explore<CR>
:map <silent> <leader>f :normal! gg=G<CR>
