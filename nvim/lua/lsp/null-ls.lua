local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local sources = {
	formatting.eslint,
	formatting.stylua,
	formatting.phpcsfixer,
	diagnostics.phpcs,
}

null_ls.setup({
	sources = sources,
})
