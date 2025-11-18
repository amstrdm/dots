return {
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
      "telescope.nvim",
    },
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end,
  },
}
