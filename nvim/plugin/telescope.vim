if !exists('g:vscode')
lua << EOF
require("telescope").setup({
    defaults = {
        path_display = {"smart"},
        file_ignore_patterns = {'%cache/*', '%var/*'},
    }
})
EOF
endif
