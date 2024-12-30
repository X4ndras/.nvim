local m = {}

function m.setup()
    require('firefly.opt')
    require('firefly.lazy')

    require('firefly.remap')
    require'colorizer'.setup()

    require('firefly.remap')
    require'colorizer'.setup()

    --vim.cmd('colorscheme firely')
    require("firefly-theme").colorize()
    --vim.cmd('Colorscheme firefly')
    vim.cmd('hi @punctuation.delimiter.c guifg=#FF0000')

    -- require('firefly.plugins.coc')

    require('firefly.plugins.telescope')

    -- require('firefly.plugins.mason')
    -- require('firefly.plugins.mason')
    require('firefly.plugins.lspconfig')

    require('firefly.plugins.cmp')


    require('firefly.plugins.autotag')
    require('firefly.plugins.treesitter')
end

return m
