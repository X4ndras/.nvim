local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

local lspsaga = require('lspsaga')
lspsaga.setup({
    code_action = {
        keys = {
            quit = '<M-;>',
            exec = '<M-i>'
        }
    },
    rename = {
        keys = {
            quit = '<M-;>',
            exec = '<M-i>'
        }
    }
})

---@diagnostic disable-next-line: unused-local
local lsp_attach = function(client, buf)
	-- Example maps, set your own with vim.api.nvim_buf_set_keymap(buf, "n", <lhs>, <rhs>, { desc = <desc> })
	-- or a plugin like which-key.nvim
	-- <lhs>        <rhs>                        <desc>
	-- "K"          vim.lsp.buf.hover            "Hover Info"
	-- "<leader>qf" vim.diagnostic.setqflist     "Quickfix Diagnostics"
	-- "[d"         vim.diagnostic.goto_prev     "Previous Diagnostic"
	-- "]d"         vim.diagnostic.goto_next     "Next Diagnostic"
	-- "<leader>e"  vim.diagnostic.open_float    "Explain Diagnostic"
	-- "<leader>ca" vim.lsp.buf.code_action      "Code Action"
	-- "<leader>cr" vim.lsp.buf.rename           "Rename Symbol"
	-- "<leader>fs" vim.lsp.buf.document_symbol  "Document Symbols"
	-- "<leader>fS" vim.lsp.buf.workspace_symbol "Workspace Symbols"
	-- "<leader>gq" vim.lsp.buf.formatting_sync  "Format File"
	vim.api.nvim_buf_set_keymap(buf, "n", "<M-f>",
        "<cmd>lua vim.diagnostic.setqflist()<CR>",
        { desc = "Quickfix Diagnostics", noremap = true, silent = true })

	vim.api.nvim_buf_set_keymap(buf, "n", "<M-r>",
        "<cmd>Lspsaga rename .<CR>",
        { desc = "Rename Symbol", noremap = true, silent = true })

	vim.api.nvim_buf_set_keymap(buf, "n", "<M-a>",
        "<cmd>Lspsaga code_action<CR>",
        { desc = "Code Action", noremap = true, silent = true })

	vim.api.nvim_buf_set_keymap(buf, "n", "[[",
        "<cmd>lua vim.diagnostic.goto_prev()<CR>",
        { desc = "Quickfix Diagnostics", noremap = true, silent = false })

	vim.api.nvim_buf_set_keymap(buf, "n", "]]",
        "<cmd>lua vim.diagnostic.goto_next()<CR>",
        { desc = "Quickfix Diagnostics", noremap = true, silent = false })

    vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
	vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc")

    print("attaching to buf")
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
    -- By default all available servers are set up. Exclude unwanted or misbehaving servers.
    excluded_servers = { "buf_ls", "ccls", "clangd", "sourcekit " },
    -- Alternatively specify preferred servers for a filetype (others will be ignored).
    preferred_servers = {
        html = { "html", "ts_ls", "cssls" },
        python = { "pyright" },
        lua = { "lua_ls" }
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
        html = {
            settings = {
                format = {
                    tabSize = 2,
                    insertSpaces = true
                }
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
        pyright = {
            settings = {
                python = {
                    pythonPath = vim.loop.cwd() .. "/.venv/Scripts/python.exe"
                }

            }
        }
    },
}

-- Setup clangd manually
lspconfig.clangd.setup{
    capabilities = capabilities
}

--[[
vim.g.rustaceanvim = {
  server = {
    on_attach = lsp_attach,
  },
}



lspconfig.pyright.setup {
    settings = {
        python = {
            pythonPath = vim.loop.cwd() .. "/.venv/Scripts/python.exe"
        }
    }
}

lspconfig.lua_ls.setup {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
}

--[[
lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            }
        }
    }
})

local languages = {
    "html",
    "cssls",
    "clangd",
    "ts_ls",
    "gopls"
    --"dockerls",
    --"htmx"
}

for _, lang in pairs(languages) do
    lspconfig[lang].setup{
        capabilities = capabilities
    }
end

]]--
