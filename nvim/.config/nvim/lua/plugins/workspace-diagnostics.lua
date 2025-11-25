return {
  "artemave/workspace-diagnostics.nvim",
  -- Load this plugin when an LSP attaches to a buffer
  event = "LspAttach",
  config = function()
    require("workspace-diagnostics").setup({
      -- Optional: ignore specific paths or filetypes here
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        require("workspace-diagnostics").populate_workspace_diagnostics(client, args.buf)
      end,
    })
  end,
}
