local m = {}

function m.setup()
    require('firefly.opt')
    require('firefly.lazy')

    require('firefly.remap')
    require'colorizer'.setup()

    vim.cmd('colorscheme firely')

    -- require('firefly.plugins.coc')

    require('firefly.plugins.telescope')

    -- require('firefly.plugins.mason')
    require('firefly.plugins.lspconfig')

    require('firefly.plugins.cmp')

    require('firefly.plugins.autotag')
    require('firefly.plugins.treesitter')
end

return m
