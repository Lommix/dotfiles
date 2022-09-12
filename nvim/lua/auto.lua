-- auto commands here
local group = vim.api.nvim_create_augroup("autocmd",{clear = true })

-- auto center cursor
vim.api.nvim_create_autocmd("CursorMoved",{
    command = "normal! zz",
    group = group
})

-- auto format
--vim.api.nvim_create_autocmd("BufWritePre", {
    -- command = vim.lsp.buf.formatting,
    -- group = group
--})

