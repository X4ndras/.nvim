local m = {}

function m.setup()
    vim.hl = vim.highlight

    -- Minimal immediate setup to prevent white flash
    vim.opt.termguicolors = true
    vim.opt.background = "dark"
    vim.api.nvim_set_hl(0, "Normal", { bg = "#0d0c0c", fg = "#c5c9c5" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#0d0c0c" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#0d0c0c" })

    -- Core settings (synchronous, fast)
    require('firefly.opt')
    require('firefly.remap')

    -- Lazy.nvim handles all plugin loading and configuration
    require('firefly.lazy')

    -- Load theme fully async after nvim starts
    vim.schedule(function()
        require("firefly-theme").setup({
            persist_theme = true,
            default_theme = "kanagawa-dragon",
        })
        require("firefly-theme").colorize()
    end)
end

return m
