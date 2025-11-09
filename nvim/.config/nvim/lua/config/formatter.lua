require("conform").setup({
  -- Formatters defined by filetype
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    -- Add any other filetypes you use
  },
  -- Set formatting to run automatically on save (optional but recommended)
  format_on_save = {
    lsp_format = "fallback", -- Use the LSP formatter as a fallback
    async = false, -- Set to true for non-blocking save
    timeout_ms = 500,
  },
})

-- Keymap to manually format the current buffer
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format()
end, { desc = "Format file or selection" })
