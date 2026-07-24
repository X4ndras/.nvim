local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lazy_lsp = require("lazy-lsp")

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

local ts_ls_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
}

local vue_language_server_path

local function resolve_vue_language_server_path()
  if vue_language_server_path ~= nil then
    return vue_language_server_path
  end

  local expr = [[let pkgs = import <nixpkgs> {}; in pkgs.nodePackages."@vue/language-server".outPath]]
  local result = vim.system({
    "nix",
    "--extra-experimental-features",
    "nix-command",
    "eval",
    "--raw",
    "--impure",
    "--expr",
    expr,
  }, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify(
      "Could not resolve @vue/language-server from Nixpkgs; Vue TS support will be incomplete.",
      vim.log.levels.WARN
    )
    vue_language_server_path = false
    return nil
  end

  local out_path = vim.trim(result.stdout)
  vue_language_server_path = out_path .. "/lib/language-tools/packages/language-server"
  return vue_language_server_path
end

local function vue_typescript_plugin()
  local location = resolve_vue_language_server_path()
  if not location then
    return nil
  end

  return {
    name = "@vue/typescript-plugin",
    location = location,
    languages = { "vue" },
    configNamespace = "typescript",
  }
end

local function vue_ts_request_forwarder(client)
  local retries = 0
  local max_retries = 120
  local retry_delay_ms = 250

  ---@param _ lsp.ResponseError
  ---@param result any
  ---@param context lsp.HandlerContext
  local function typescript_handler(_, result, context)
    local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })[1]
      or vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })[1]
      or vim.lsp.get_clients({ bufnr = context.bufnr, name = "typescript-tools" })[1]

    if not ts_client then
      if retries < max_retries then
        retries = retries + 1
        vim.defer_fn(function()
          typescript_handler(_, result, context)
        end, retry_delay_ms)
      else
        vim.notify(
          "Could not find `ts_ls`, `vtsls`, or `typescript-tools` lsp client required by `vue_ls`.",
          vim.log.levels.ERROR
        )
      end
      return
    end

    local id, command, payload = unpack(assert(result))
    ts_client:exec_cmd({
      title = "vue_request_forward",
      command = "typescript.tsserverRequest",
      arguments = {
        command,
        payload,
      },
    }, { bufnr = context.bufnr }, function(_, response)
      local response_data = { { id, response and response.body } }
      ---@diagnostic disable-next-line: param-type-mismatch
      client:notify("tsserver/response", response_data)
    end)
  end

  client.handlers["tsserver/request"] = typescript_handler
end

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

lazy_lsp.setup {
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
    vue        = { "vue_ls", "ts_ls" },
  },
  configs = {
    ts_ls = {
      -- Keep ts_ls on a static command so lazy-lsp can provision it from Nix.
      cmd = lazy_lsp.in_shell({
        "typescript-language-server",
        "typescript",
        'nodePackages."@vue/language-server"',
      }, {
        "typescript-language-server",
        "--stdio",
      }),
      filetypes = ts_ls_filetypes,
      before_init = function(_, config)
        local vue_plugin = vue_typescript_plugin()
        if not vue_plugin then
          return
        end

        config.init_options = config.init_options or {}
        config.init_options.plugins = config.init_options.plugins or {}

        local has_vue_plugin = vim.iter(config.init_options.plugins):any(function(plugin)
          return plugin.name == vue_plugin.name
        end)
        if not has_vue_plugin then
          table.insert(config.init_options.plugins, vue_plugin)
        end
      end,
    },
    vue_ls = {
      on_init = vue_ts_request_forwarder,
    },
  },
  prefer_local = false,
}

-- Neovim 0.12 + lazy-lsp's vim.lsp.config path currently skips some upstream
-- configs whose `cmd` is a function (for example ts_ls). Enable the servers we
-- actually rely on when lazy-lsp reports that it skipped them.
local lazy_lsp_issues = require("lazy-lsp.state").get_issues()
local skipped_dynamic_cmd_servers = {}
for _, issue in ipairs(lazy_lsp_issues) do
  local server = issue.message:match("^([%w_]+) has dynamic `cmd`, config will not work$")
  if server then
    skipped_dynamic_cmd_servers[server] = true
  end
end

for _, server in ipairs({ "ts_ls", "html", "cssls", "jsonls", "yamlls", "eslint" }) do
  if skipped_dynamic_cmd_servers[server] then
    vim.lsp.enable(server)
  end
end

if vim.fn.exists(":LspInfo") == 0 then
  vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
    desc = "Alias to :checkhealth vim.lsp",
  })
end

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
