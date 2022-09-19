local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local sources = {
	--formatting.eslint,
	formatting.prettier,
	formatting.stylua,
	formatting.phpcsfixer,
	--diagnostics.phpcs,
	--diagnostics.phpstan,
	--formatting.phpcbf,
	--diagnostics.psalm,
}

null_ls.setup({
	sources = sources,
})
