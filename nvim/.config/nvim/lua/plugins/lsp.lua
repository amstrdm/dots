return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
            "--log=verbose",
            "--query-driver=**/arm-zephyr-eabi-g++",
            "--background-index",
          },
        },
      },
    },
  },
}
