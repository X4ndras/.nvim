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
    excluded_servers = { "buf_ls", "ccls", "clangd", "sourcekit " },
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
                    --pythonPath = vim.loop.cwd() .. "/.venv/Scripts/python.exe"
                }

            }
        }
    },
}

-- Setup clangd manually
lspconfig.clangd.setup{
    capabilities = capabilities
}

-- Function to create a floating window
local function open_floating_window()
    -- Define the text to be displayed
    local text = {
        "Goto Definition        [1]",
        "Goto Declaration       [2]",
        "Show Signature help    [3]",
        "Goto Implementation    [4]",
        "Show References        [5]",
        "Show Quickfix          [6]",
    }

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- create new empty buffer

    -- Set buffer lines
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)

    -- Setup window dimensions
    local width = #text[1]
    local height = #text

    -- Create window configuration
    local opts = {
        style = "minimal",
        relative = "cursor",
        width = width,
        height = height,
        row = 1,
        col = 1,
        border = "rounded"
    }

    local _ = vim.api.nvim_open_win(buf, true, opts)

    -- Set key mapping to close the window
    vim.api.nvim_buf_set_keymap(buf, 'n', '<M-;>', '<cmd>bd!<CR>', {nowait = true, noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', {nowait = true, noremap = true, silent = true})

    vim.api.nvim_buf_set_keymap(buf, 'n', '1', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.definition()<CR>',
        {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '2', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.declaration()<CR>',
        {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '3', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.signature_help()<CR>',
        {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '4', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.implementation()<CR>',
        {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '5', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.references()<CR>',
        {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '6', '<cmd>bd!<CR><cmd>lua vim.lsp.buf.code_action()<CR>',
        {noremap = true, silent = true})
end

-- Map the function to a key binding (e.g., <Leader>fw to open the floating window)
vim.keymap.set('n', '<leader>m', function() open_floating_window() end, {noremap = true, silent = true})
