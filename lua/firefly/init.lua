local m = {}

function m.setup()
    vim.hl = vim.highlight

    -- Disable netrw in favor of Telescope / file tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

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

    -- If Neovim was started with a directory argument (e.g. `nvim .`),
    -- open Telescope file browser instead of a tree/netrw view.
    vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
            local argv = vim.fn.argv()
            if #argv ~= 1 then
                return
            end

            local path = argv[1]
            if vim.fn.isdirectory(path) ~= 1 then
                return
            end

            local ok, telescope = pcall(require, 'telescope')
            if not ok then
                return
            end

            local fb = telescope.extensions and telescope.extensions.file_browser
            if not fb or not fb.file_browser then
                return
            end

            fb.file_browser({
                path = path,
                select_buffer = true,
            })
        end,
    })

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
