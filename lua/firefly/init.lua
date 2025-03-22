local m = {}

function m.setup()
    vim.hl = vim.highlight

    require('firefly.opt')
    require('firefly.lazy')
    require('firefly.remap')

    require'colorizer'.setup()
    require('firefly.plugins.harpoon')

    require('firefly.plugins.telescope')
    require('firefly.plugins.lspconfig')
    require('firefly.plugins.cmp')
    require('firefly.plugins.autotag')
    require('firefly.plugins.treesitter')

    require("firefly-theme").colorize()
    --vim.api.nvim_command("Colorscheme one-dark")

    require("firefly.plugins.ai")

    --require("firefly.plugins.ai")
    -- require("firefly.plugins.bufopt")
    --local copilot = require("firefly.plugins.copilot")
    --vim.keymap.set("n", "<Leader>cc", function() copilot.complete() end)
    --vim.keymap.set("n", "<Leader>ca", function() copilot.accept_completion() end)
    --vim.keymap.set("n", "<Leader>cd", function() copilot.discard_completion() end)
end

return m
