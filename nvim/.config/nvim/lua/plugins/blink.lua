return {
  {
    "saghen/blink.cmp",
    opts = {
      -- turn off the preset so our keys take effect
      keymap = {
        preset = "none",
        -- accept with Tab; if in snippet, jump; otherwise fall back
        ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        -- navigate suggestions
        ["<C-j>"] = { "select_next" },
        ["<C-k>"] = { "select_prev" },

        -- scroll docs
        ["<C-h>"] = { "scroll_documentation_up" },
        ["<C-l>"] = { "scroll_documentation_down" },

        -- make Enter a normal newline
        ["<CR>"] = { "fallback" },
      },
    },
  },
}
