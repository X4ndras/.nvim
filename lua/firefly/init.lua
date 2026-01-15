local m = {}

function m.setup()
    vim.hl = vim.highlight

    -- Core settings (synchronous, fast)
    require('firefly.opt')
    require('firefly.remap')

    -- Lazy.nvim handles all plugin loading and configuration
    -- Plugins are loaded on-demand based on events, commands, and keymaps
    require('firefly.lazy')
end

return m
