return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      {
        "<leader>ft",
        function()
          vim.cmd(vim.v.count1 .. "ToggleTerm")
        end,
        desc = "Terminal (ToggleTerm) [count]",
      },
      {
        "<leader>fT",
        function()
          -- you can still use a count here if you want: 2<leader>fT, etc.
          vim.cmd(vim.v.count1 .. "ToggleTerm direction=tab")
        end,
        desc = "Terminal Tab (ToggleTerm) [count]",
      },
    },
    config = function()
      require("toggleterm").setup({
        direction = "float",
        float_opts = { border = "rounded" },
      })
    end,
  },
}
