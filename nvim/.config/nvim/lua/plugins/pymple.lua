return {
  {
    "alexpasmantier/pymple.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- optional (nicer ui)
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = ":PympleBuild",
    config = function()
      require("pymple").setup({
        logging = {
          file = {
            enabled = true,
            path = vim.fn.stdpath("data") .. "/pymple.vlog",
            max_lines = 1000, -- feel free to increase this number
          },
          -- this might help in some scenarios
          console = {
            enabled = false,
          },
          level = "debug",
        },
      })
    end,
  },
}
