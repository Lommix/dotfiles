local status_ok, signature = pcall(require, "lsp_signature")
if not status_ok then
	return
end

signature.setup({
    hint_enable = false,
	doc_lines = 0,
    floating_window_off_y = 0,
    floating_window_off_x = 0,
})
