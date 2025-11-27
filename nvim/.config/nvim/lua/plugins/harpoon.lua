return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = function()
      local harpoon = require("harpoon")

      local keys = {
        -- 1. Append to end of list: <leader>haa
        {
          "<leader>haa",
          function()
            harpoon:list():add()
          end,
          desc = "Harpoon Append File",
        },

        -- 2. Toggle the Standard UI: <leader>ht
        {
          "<leader>ht",
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Toggle Menu",
        },
      }

      -- 3. Loop: Navigate to file (<leader>h1, <leader>h2...)
      for i = 1, 9 do
        table.insert(keys, {
          "<leader>h" .. i,
          function()
            harpoon:list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end

      -- 4. Loop: Add to specific index (<leader>ha1, <leader>ha2...)
      -- Uses replace_at(i) to force the file into that specific slot
      for i = 1, 9 do
        table.insert(keys, {
          "<leader>ha" .. i,
          function()
            harpoon:list():replace_at(i)
          end,
          desc = "Harpoon Add to Index " .. i,
        })
      end

      return keys
    end,

    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
        },
      })
    end,
  },
}
