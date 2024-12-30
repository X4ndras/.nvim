require('mason').setup({
    ui = {
        icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗'
        }
    }
})

-- mason lspconfig

-- php installed via intellephense
require('mason-lspconfig').setup {
    ensure_installed = {
        --'rust_analyzer',
        --'htmx',
        --'gopls',
        'lua_ls',
        'pyright',
        'clangd',
        'html',
        'cssls',
        'ts_ls',
    },
}
