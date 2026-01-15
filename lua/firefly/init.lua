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

    -- Setup firefly-theme with optional config
    -- persist_theme: auto-save and restore last used theme (default: true)
    -- default_theme: fallback theme if no saved theme exists (default: nil)
    require("firefly-theme").setup({
        persist_theme = true,
        default_theme = "kanagawa-dragon",  -- Fallback if no saved theme
    })
    require("firefly-theme").colorize()

    require("firefly.plugins.ai")

    --require("firefly.plugins.ai")
    -- require("firefly.plugins.bufopt")
    --local copilot = require("firefly.plugins.copilot")
    --vim.keymap.set("n", "<Leader>cc", function() copilot.complete() end)
    --vim.keymap.set("n", "<Leader>ca", function() copilot.accept_completion() end)
    --vim.keymap.set("n", "<Leader>cd", function() copilot.discard_completion() end)
end

return m
