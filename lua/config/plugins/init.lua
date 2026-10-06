require("config.plugins.telescope")
require("config.plugins.diffview")
require("config.plugins.neo-tree")
require("config.plugins.mason")
require("config.plugins.treesitter")

-- other plugin setups
require("gitsigns").setup({})

-- Prefer the local leadm checkout over the packaged one while developing.
local dev_leadm = vim.fn.expand("~/Downloads/leadm.nvim")

if vim.uv.fs_stat(dev_leadm) then
  vim.opt.runtimepath:prepend(dev_leadm)
end

require("config.plugins.leadm")

local dev_firefly = vim.fn.expand("~/Downloads/firefly.nvim")

if vim.uv.fs_stat(dev_firefly) then
    vim.opt.runtimepath:prepend(dev_firefly)
end


require("firefly").setup({
  -- theme = "firefly",
  -- themes_dir = nil,
  -- persist = true,
  transparent = true,
  -- italic_comments = true,
  -- dim_inactive = false,
  statusline = {
    enabled = false,
    global = false,
  },
  -- command = { enabled = true, name = "Firefly", },
  palette = {},
  mappings = {},
  diagnostics = {},
  highlights = {},
})

