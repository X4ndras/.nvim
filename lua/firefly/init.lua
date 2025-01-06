local m = {}

function m.setup()
    require('firefly.opt')
    require('firefly.lazy')
    require('firefly.remap')

    require'colorizer'.setup()

    require('firefly.plugins.telescope')
    require('firefly.plugins.lspconfig')
    require('firefly.plugins.cmp')
    require('firefly.plugins.autotag')
    require('firefly.plugins.treesitter')

    require("firefly-theme").colorize()
    vim.cmd('hi @punctuation.delimiter.c guifg=#FF0000')

    --local copilot = require("firefly.plugins.copilot")
    --vim.keymap.set("n", "<Leader>cc", function() copilot.complete() end)
    --vim.keymap.set("n", "<Leader>ca", function() copilot.accept_completion() end)
    --vim.keymap.set("n", "<Leader>cd", function() copilot.discard_completion() end)
end

return m
