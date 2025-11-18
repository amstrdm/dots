vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

vim.keymap.set(
  "n",
  "<leader>fW",
  "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
  { desc = "Find Worktrees" }
)
vim.keymap.set(
  "n",
  "<leader>fw",
  "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
  { desc = "New Worktree" }
)
