local M = {}

M.server_capabilities = function()
  local active_clients = vim.lsp.get_active_clients()
  local active_client_map = {}

  for index, value in ipairs(active_clients) do
    active_client_map[value.name] = index
  end

  vim.ui.select(vim.tbl_keys(active_client_map), {
    prompt = "Select client:",
    format_item = function(item)
      return "capabilites for: " .. item
    end,
  }, function(choice)
    -- print(active_client_map[choice])
    print(vim.inspect(vim.lsp.get_active_clients()[active_client_map[choice]].server_capabilities.executeCommandProvider))
    vim.pretty_print(vim.lsp.get_active_clients()[active_client_map[choice]].server_capabilities)
  end)
end

--require 'lsp.handlers'.setup()
require 'lommix.lsp.mason'
require 'lommix.lsp.null-ls'
require 'lspconfig'
require 'lommix.lsp.mason-null-ls'
require 'lommix.lsp.lsp_signature'
require 'lommix.lsp.handlers'.setup()

return M