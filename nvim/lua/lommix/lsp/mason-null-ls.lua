local ok, mason_null_ls = pcall(require, "mason-null-ls")
if not ok then
	return
end

local ok2, null_ls = pcall(require, "null-ls")
if not ok2 then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local actions = null_ls.builtins.code_actions

local sources = {
	formatting.eslint_d,
	formatting.stylua,

	diagnostics.eslint_d,
	--diagnostics.phpcs, -- not hard enough
	--diagnostics.psalm,
	actions.xo, -- js/ts
}

null_ls.setup({
	sources = sources,
})

mason_null_ls.setup({
	automatic_installation = true,
})
