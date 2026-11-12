return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- 1. Match word under cursor (VS Code Cmd+D / Ctrl+D style)
      set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "Add cursor at next match" })
      set({ "n", "x" }, "<C-x>", function() mc.matchSkipCursor(1) end, { desc = "Skip match" })

      -- 2. Add cursor vertically
      set({ "n", "x" }, "<C-Up>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })
      set({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })

      -- 3. Clear extra cursors with Escape
      mc.addKeymapLayer(function(layerSet)
        layerSet("n", "<esc>", mc.clearCursors)
      end)
    end,
  },
}
