return {
  {
    "folke/noice.nvim",
    opts = {
      -- keep the fancy command-line UI
      cmdline = { enabled = true, view = "cmdline_popup" },

      -- turn OFF Noice's message interception so :! output is native
      messages = { enabled = false },

      -- optional: keep the popupmenu native too (completion near bottom)
      popupmenu = { enabled = false },

      -- optional presets you might like
      presets = {
        bottom_search = false, -- keep /? search at bottom? set true if you want
        command_palette = false,
        long_message_to_split = true, -- long msgs go to a split (not required)
      },
    },
  },
}
