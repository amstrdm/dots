vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

vim.keymap.set(
  "n",
  "<leader>fw",
  "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
  { desc = "Find Worktrees" }
)
vim.keymap.set(
  "n",
  "<leader>fW",
  "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
  { desc = "New Worktree" }
)

vim.keymap.set("n", "<leader>ut", function()
  -- 1. Find the BasedPyright client
  local clients = vim.lsp.get_clients({ name = "basedpyright" })
  if #clients == 0 then
    vim.notify("BasedPyright is not active.", vim.log.levels.WARN)
    return
  end

  -- 2. Get the specific namespace ID for BasedPyright
  local client = clients[1]
  local ns = vim.lsp.diagnostic.get_namespace(client.id)

  -- 3. Check if currently enabled and toggle
  _G.basedpyright_off = not _G.basedpyright_off

  if _G.basedpyright_off then
    vim.diagnostic.enable(false, { ns_id = ns })
    vim.notify("BasedPyright (Types) Hidden", vim.log.levels.INFO)
  else
    vim.diagnostic.enable(true, { ns_id = ns })
    vim.notify("BasedPyright (Types) Visible", vim.log.levels.INFO)
  end
end, { desc = "Toggle Type Diagnostics" })

-- Resume last telescope search
vim.keymap.set("n", "<leader>sx", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })
