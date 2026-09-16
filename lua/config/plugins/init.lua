require("config.plugins.telescope")
require("config.plugins.diffview")
require("config.plugins.neo-tree")
require("config.plugins.mason")
require("config.plugins.treesitter")

-- other plugin setups
require("gitsigns").setup({})

-- Prefer the local leadm checkout over the packaged one while developing.
local dev = vim.fn.expand("~/Downloads/leadm")

if vim.uv.fs_stat(dev) then
    vim.opt.runtimepath:prepend(dev)
end

require("leadm").setup({})
