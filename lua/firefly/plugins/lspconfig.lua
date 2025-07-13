local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

local function set_tab_size(bufnr, size)
  vim.bo[bufnr].tabstop = size
  vim.bo[bufnr].shiftwidth = size
  vim.bo[bufnr].softtabstop = -1 -- Align with shiftwidth
  vim.bo[bufnr].expandtab = true -- Use spaces
end

local server_configs = {
  rust = 4,
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
  excluded_servers = { "buf_ls", "ccls", "clangd", "sourcekit", "denols", "intelliphense" },
  preferred_servers = {
    html = { "html", "ts_ls", "cssls" },
    python = { "pyright" },
    lua = { "lua_ls" },
    javascript = { "ts_ls" },
    php = { "phpactor" },
  },
  prefer_local = false,
  default_config = lsp_defaults,
  configs = {
    rust_analyzer = {
      settings = {
        checkOnSave = {
          command = "clippy",
        },
        --procMacro = {
        --  enable = true
        --},
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` and `love` globals
            globals = { "vim", "love" },
          },
          workspace = {
            -- Make the server aware of Love2D runtime libraries
            -- Use proper Neovim API to access runtime paths
            library = {
              vim.api.nvim_get_runtime_file("", true),
            },
            -- Enable to load Love2D definitions via builtin third-party library support
            checkThirdParty = true,
          },
          completion = {
            callSnippet = "Replace"
          },
          telemetry = {
            enable = false,
          },
          runtime = {
            -- Use LuaJIT for LÖVE
            version = "LuaJIT",
          },
        },
      },
    },
  }
}

-- Setup clangd manually
--lspconfig.clangd.setup {
--    capabilities = capabilities,
--    initializationOptions = lsp_defaults.initializationOptions
--}
--vim.lsp.config('clangd', {
--  -- Server-specific settings. See `:help lsp-quickstart`
--  settings = {
--    ['clangd'] = {
--      capabilities = capabilities,
--      initializationOptions = lsp_defaults.initializationOptions
--    },
--  },
--})
