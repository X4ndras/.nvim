local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function set_tab_size(bufnr, size)
  vim.bo[bufnr].tabstop = size
  vim.bo[bufnr].shiftwidth = size
  vim.bo[bufnr].softtabstop = -1 -- Align with shiftwidth
  vim.bo[bufnr].expandtab = true -- Use spaces
end

local server_configs = {
  rust = 4,
  python = 4,
  javascript = 2,
}

--- client, buf
local lsp_attach = function(_, buf)
  vim.api.nvim_buf_set_keymap(buf, "n", "[[",
    "<cmd>lua vim.diagnostic.goto_prev()<CR>",
    { desc = "Quickfix Diagnostics", noremap = true, silent = false })

  vim.api.nvim_buf_set_keymap(buf, "n", "]]",
    "<cmd>lua vim.diagnostic.goto_next()<CR>",
    { desc = "Quickfix Diagnostics", noremap = true, silent = false })

  vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
  vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
  vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc")

  ------------------------------------------------------------------
  -- Indentation rules
  ------------------------------------------------------------------
  local ft = vim.bo[buf].filetype

  -- Makefiles MUST use real <Tab> characters
  if ft == "make" then
    vim.bo[buf].expandtab   = false -- keep real tabs
    vim.bo[buf].tabstop     = 4     -- visual width (your choice)
    vim.bo[buf].shiftwidth  = 4
    vim.bo[buf].softtabstop = 0
    return
  end

  local tab_size = server_configs[ft] or 2
  -- print("Filetype:", ft, " Tab size set to:", tab_size)
  set_tab_size(buf, tab_size)
end

require("lazy-lsp").setup {
  use_vim_lsp_config = true,
  excluded_servers = {
    "buf_ls",
    "ccls",
    --"clangd",
    "sourcekit",
    "intelliphense",
    "flow",          -- prefer eslint and ts_ls
    "ltex",          -- grammar tool using too much CPU
    "quick_lint_js", -- prefer eslint and ts_ls
    "denols",
    "oxlint",        -- prefer eslint
    "scry",          -- archived on Jun 1, 2023
    "tailwindcss",   -- associates with too many filetypes
    "vuels", "vls", "volar", -- legacy Vue LSPs
  },
  preferred_servers = {
    html       = { "html", "ts_ls", "cssls" },
    python     = { "pyright" },
    lua        = { "lua_ls" },
    javascript = { "ts_ls" },
    typescript = { "ts_ls" },
  },
  prefer_local = false,
}

capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("*", {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  on_attach = {
    mine = lsp_attach,
    default = lsp_attach,
  },
  root = vim.loop.cwd(),
  general = {
    positionEncodings = { "utf-8", "utf-16" }
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--completion-style=detailed",
    "--fallback-style=llvm",
  },
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "stricter",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config("lua_ls", {
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
})
