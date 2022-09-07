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
set nohlsearch

let mapleader = "\<Space>"
nnoremap <silent> <Leader>s :split<CR>
nnoremap <silent> <Leader>v :vsplit<CR>
nnoremap <silent> <Leader>q :close<CR>
nnoremap <leader>e :wincmd v<bar> :Ex<CR>

if !exists('g:vscode')
    call plug#begin("~/.vim/plugged")
    Plug 'dracula/vim'
    Plug 'OmniSharp/omnisharp-vim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
    Plug 'vim-autoformat/vim-autoformat'
    Plug 'gruvbox-community/gruvbox'
    Plug 'dense-analysis/ale'
    Plug 'puremourning/vimspector'
    Plug 'dcampos/nvim-snippy'
    Plug 'beyondwords/vim-twig'
    Plug 'arcticicestudio/nord-vim'
    Plug 'liuchengxu/vim-which-key'
    Plug 'habamax/vim-godot'
    Plug 'junegunn/fzf.vim'
    Plug 'skywind3000/asyncrun.vim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    call plug#end()

    set completeopt=menu,menuone,noselect

lua <<EOF

    require'lspconfig'.gdscript.setup{}
    require'lspconfig'.tsserver.setup{}
    require'lspconfig'.omnisharp.setup{}
    require'lspconfig'.bashls.setup{}
    require'lspconfig'.rust_analyzer.setup{}
    require'lspconfig'.dockerls.setup{}
    require'lspconfig'.phpactor.setup{}

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local snippy = require("snippy")
    -- Set up nvim-cmp.
    local cmp = require'cmp'
    cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
        },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
        },
    mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, { "i", "s" }),

    }),
sources = cmp.config.sources({
{ name = 'nvim_lsp' },
{ name = 'vsnip' }, -- For vsnip users.
-- { name = 'luasnip' }, -- For luasnip users.
-- { name = 'ultisnips' }, -- For ultisnips users.
-- { name = 'snippy' }, -- For snippy users.
}, {
{ name = 'buffer' },
})
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
      }, {
      { name = 'buffer' },
      })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
          { name = 'buffer' }
          }
      })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
      { name = 'path' }
      }, {
      { name = 'cmdline' }
      })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
      capabilities = capabilities
      }
EOF


  syntax enable
  colorscheme gruvbox
  highlight Normal ctermbg=none

  "------------------- Mappings
  ":verbose imap <tab>
  nnoremap <silent> <leader> :silent WhichKey ''<CR>
  nnoremap <leader>ff <cmd>Telescope find_files<cr>
  nnoremap <leader>fg <cmd>Telescope live_grep<cr>
  nnoremap <leader>fb <cmd>Telescope buffers<cr>
  nnoremap <leader>fh <cmd>Telescope help_tags<cr>
  nnoremap <leader>f <cmd>Autoformat<cr>
  nnoremap <leader>ps :lua require('telescope.builtin').grep_string({search = vim.fn.input("Grep For >")})<CR>

  " LSP config (the mappings used in the default file don't quite work right)
  nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
  nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
  nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
  nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

  " DEBUGGER

  if !has("ide")
      "let g:vimspector_enable_mappings = 'HUMAN'
      nmap <leader>dd :call vimspector#Launch()<CR>
      nmap <leader>dx :call vimspector#Reset()<CR>
      nmap <leader>dc :call vimspector#Continue()<CR>
      nmap <leader>tb <Plug>VimspectorToggleBreakpoint
      nmap <leader>si <Plug>VimspectorStepInto
      nmap <leader>so <Plug>VimspectorStepOver
      nmap <leader>su <Plug>VimspectorStepOut
      "autocmd FileType java nmap <leader>dd :CocCommand java.debug.vimspector.start<CR>
  endif

  " Move windows
  nnoremap <A-h> <C-w>h
  nnoremap <A-j> <C-w>j
  nnoremap <A-k> <C-w>k
  nnoremap <A-l> <C-w>l

  " Move windows mac
  nnoremap ª <C-w>h
  nnoremap º <C-w>j
  nnoremap ∆ <C-w>k
  nnoremap @ <C-w>l

  nnoremap <leader>j :resize -2<CR>
  nnoremap <leader>k :resize +2<CR>
  nnoremap <leader>h :vertical resize -2<CR>
  nnoremap <leader>l :vertical resize +2<CR>

  let g:ale_linters = {
              \ 'cs': ['OmniSharp']
              \}

  " Enable ALE auto completion globally
  "let g:ale_completion_enabled = 1

  " Allow ALE to autoimport completion entries from LSP servers
  "let g:ale_completion_autoimport = 1

  " Register LSP server for Godot:
  call ale#linter#Define('gdscript', {
              \   'name': 'godot',
              \   'lsp': 'socket',
              \   'address': '127.0.0.1:6008',
              \   'project_root': 'project.godot',
              \})
endif

augroup KeepCentered
    autocmd!
    autocmd CursorMoved * normal! zz
augroup END
