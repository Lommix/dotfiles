set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set relativenumber
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set wildmenu
set wildmode=longest:full,full
set backupdir=~/.cache/vim " Directory to store backup files.


call plug#begin("~/.vim/plugged")
Plug 'dracula/vim'
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --forzen-lockfile'}
Plug 'OmniSharp/omnisharp-vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'vim-autoformat/vim-autoformat'
Plug 'gruvbox-community/gruvbox'
Plug 'dense-analysis/ale'
Plug 'puremourning/vimspector'
Plug 'beyondwords/vim-twig'
Plug 'arcticicestudio/nord-vim'
call plug#end()


"------------------- Plugin Configs
let g:coc_global_extensions = [
            \ 'coc-tsserver',
            \ 'coc-html',
            \ 'coc-rust-analyzer',
            \ 'coc-css',
            \ 'coc-highlight',
            \ 'coc-json',
            \ 'coc-blade',
            \ 'coc-sql',
            \ 'coc-docker',
            \ 'coc-pairs',
            \ 'coc-emmet',
            \ '@yaegassy/coc-tailwindcss3',
            \ '@yaegassy/coc-intelephense',
            \ ]

syntax enable
colorscheme nord
highlight Normal guibg=none

"------------------- Mappings
let mapleader = "\<Space>"
":verbose imap <tab>
nnoremap <leader>e :wincmd v<bar> :Ex<CR>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>f <cmd>Autoformat<cr>
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({search = vim.fn.input("Grep For >")})<CR>

nnoremap <silent> <Leader>s :split<CR>
nnoremap <silent> <Leader>v :vsplit<CR>
nnoremap <silent> <Leader>q :close<CR>
" DEBUGGER
"let g:vimspector_enable_mappings = 'HUMAN'
nmap <leader>dd :call vimspector#Launch()<CR>
nmap <leader>dx :call vimspector#Reset()<CR>
nmap <leader>dc :call vimspector#Continue()<CR>
nmap <leader>tb <Plug>VimspectorToggleBreakpoint
nmap <leader>si <Plug>VimspectorStepInto
nmap <leader>so <Plug>VimspectorStepOver
nmap <leader>su <Plug>VimspectorStepOut
autocmd FileType java nmap <leader>dd :CocCommand java.debug.vimspector.start<CR>

" Move windows
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" Move windows mac
nnoremap ª <C-w>h
nnoremap º <C-w>j
nnoremap ∆ <C-w>k
nnoremap @ <C-w>l

nnoremap <leader>j :resize -2<CR>
nnoremap <leader>k :resize +2<CR>
nnoremap <leader>h :vertical resize -2<CR>
nnoremap <leader>l :vertical resize +2<CR>

if has("ide")
    :map <leader>td <Action>(ToggleLineBreakpoint)
    :map <leader>dd <Action>(Debug)
    :map <leader>ff <Action>(GotoFile)
    :map <leader>fs <Action>(Switcher)
endif

let g:ale_linters = {
            \ 'cs': ['OmniSharp']
            \}

"autocmd CursorHold *.cs OmniSharpTypeLookup
"
"" Asyncomplete: {{{
"let g:asyncomplete_auto_popup = 1
"let g:asyncomplete_auto_completeopt = 1
"" }}}
"
"" OmniSharp: {{{
"let g:OmniSharp_popup_position = 'peek'
"if has('nvim')
"  let g:OmniSharp_popup_options = {
"  \ 'winhl': 'Normal:NormalFloat'
"  \}
"else
"  let g:OmniSharp_popup_options = {
"  \ 'highlight': 'Normal',
"  \ 'padding': [0, 0, 0, 0],
"  \ 'border': [1]
"  \}
"endif
"let g:OmniSharp_popup_mappings = {
            "\ 'sigNext': '<C-n>',
            "\ 'sigPrev': '<C-p>',
            "\ 'pageDown': ['<C-f>', '<PageDown>'],
            "\ 'pageUp': ['<C-b>', '<PageUp>']
"\}
"
"let g:OmniSharp_highlight_groups = {
            "\ 'ExcludedCode': 'NonText'
"\}
"" }}}
"
"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline#extensions#tabline#buffer_nr_show = 1
"let g:airline_right_sep = ""
"let g:airline_left_sep = ""
"
"" ALE
"let g:ale_completion_autoimport = 1
