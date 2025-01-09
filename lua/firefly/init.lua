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
    vim.cmd('hi @punctuation.delimiter.c guifg=#FF0000')

    local bufoptts = require("bufopt")
    vim.keymap.set('n', '<leader>m', bufoptts.open_floating_window, { noremap = true, silent = true })

    vim.api.nvim_set_hl(0, "netrwMarkFile", { link = "Search" })

    -- require("firefly.plugins.bufopt")

    --local copilot = require("firefly.plugins.copilot")
    --vim.keymap.set("n", "<Leader>cc", function() copilot.complete() end)
    --vim.keymap.set("n", "<Leader>ca", function() copilot.accept_completion() end)
    --vim.keymap.set("n", "<Leader>cd", function() copilot.discard_completion() end)
end

return m
