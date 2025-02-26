local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

local function set_tab_size(bufnr, size)
    vim.bo[bufnr].tabstop = size
    vim.bo[bufnr].shiftwidth = size
    vim.bo[bufnr].softtabstop = -1 -- Align with shiftwidth
    vim.bo[bufnr].expandtab = true -- Use spaces
end

local server_configs = {
    go              = 2,
    html            = 2,
    css             = 2,
    typescript      = 2,
    javascript      = 2,
    yaml            = 2,
}

local lsp_attach = function(client, buf)
    vim.api.nvim_buf_set_keymap(buf, "n", "[[",
        "<cmd>lua vim.diagnostic.goto_prev()<CR>",
        { desc = "Quickfix Diagnostics", noremap = true, silent = false })

    vim.api.nvim_buf_set_keymap(buf, "n", "]]",
        "<cmd>lua vim.diagnostic.goto_next()<CR>",
        { desc = "Quickfix Diagnostics", noremap = true, silent = false })

    vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
    vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc")

    local server_name = vim.bo[buf].filetype
    local tab_size = server_configs[server_name] or 2
    set_tab_size(buf, tab_size)
    --print("Setting tab size to " .. tab_size .. " for " .. server_name)
end

local lsp_defaults = {
    flags = {
        debounce_text_changes = 150,
    },
    root = vim.loop.cwd(),
    capabilities = capabilities,
    on_attach = lsp_attach,
}

lsp_defaults.capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.util.default_config = vim.tbl_deep_extend(
    'force',
    lspconfig.util.default_config,
    lsp_defaults
)

require("lazy-lsp").setup {
    excluded_servers = { "buf_ls", "ccls", "clangd", "sourcekit", "denols" },
    preferred_servers = {
        html = { "html", "ts_ls", "cssls" },
        python = { "pyright" },
        lua = { "lua_ls" },
        javascript = { "ts_ls" }
    },
    prefer_local = false,
    default_config = {
        flags = {
            debounce_text_changes = 150,
        },
        on_attach = lsp_attach,
        capabilities = capabilities
    },
    configs = {
        rust_analyzer = {
            settings = {
                checkOnSave = {
                    command = "clippy",
                },
                lens = {
                    enable = true,
                    references = {
                        adt = { enable = true },
                        enumVariant = { enable = true },
                        method = { enable = true },
                        trait = { enable = true },
                    },
                },
                procMacro = {
                    enable = true
                },
            }
        },
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { "vim" },
                    },
                },
            },
        },
    }
}

-- Setup clangd manually
lspconfig.clangd.setup {
    capabilities = capabilities
}
