-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.keymap.set("n", "<leader>r", function()
  vim.cmd("w") -- save
  vim.cmd("!go run .")
end, { desc = "Run Go project" })

vim.api.nvim_create_user_command("GoRun", function()
  vim.cmd("w") -- save file
  vim.cmd("!go run .")
end, { desc = "Run current Go module" })
