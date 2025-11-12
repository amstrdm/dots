return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  keys = {
    -- Power search: show ALL files (hidden + ignored)
    {
      "<leader>fa",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          no_ignore = true,
          follow = true,
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--no-ignore",
            "--follow",
            "--exclude",
            ".git",
          },
        })
      end,
      desc = "Find ALL files (hidden + ignored)",
    },
  },
}
