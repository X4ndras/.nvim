local cmp = require('cmp')
local luasnip = require("luasnip")
local lspkind = require('lspkind')

require("luasnip.loaders.from_vscode").lazy_load({})

require("luasnip").setup({
    history = true,
    delete_check_events = 'TextChanged',
})


-- autopairs setup
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

cmp.setup({
    --preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },

    snippet = {
      -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },

    window = {
        completion = { border = 'rounded', scrollbar = '║', },
        documentation = { border = 'rounded', scrollbar = '║', }
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-J>'] = cmp.mapping.scroll_docs(4),
        ['<C-K>'] = cmp.mapping.scroll_docs(-4),
        ['<M-o>'] = cmp.mapping.abort(),
        ['<M-i>'] = cmp.mapping.confirm({ select = true }),

        ['<M-j>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            elseif cmp.has_words_before() then
                cmp.complete()
            else fallback() end
        end, { 'i', 's' }),

        ['<M-k>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),

    sources = cmp.config.sources({
        {
            name = 'nvim_lsp',
            priority = 1
        },
        {
            name = 'luasnip',
            priority = 2
        },
        { name = "ollama" },
        { name = 'nvim_lsp_signature_help' },
        { name = 'path' },
    }, {
        { name = 'buffer' },
        { name = 'cmdline' },
    }),

    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            preset = 'codicons',

            symbol_map = {
                Text = "󰉿",
                Method = "󰆧",
                Function = "󰊕",
                Constructor = "",
                Field = "󰜢",
                Variable = "󰀫",
                Class = "󰠱",
                Interface = "",
                Module = "",
                Property = "󰜢",
                Unit = "󰑭",
                Value = "󰎠",
                Enum = "",
                Keyword = "󰌋",
                Snippet = "",
                Color = "󰏘",
                File = "󰈙",
                Reference = "󰈇",
                Folder = "󰉋",
                EnumMember = "",
                Constant = "󰏿",
                Struct = "󰙅",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "",
            },
        }),
    },
    experimental = {
        ghost_text = {enabled = true, hl_group = 'GhostText' },
    },
})


-- Keymaps for Luasnip
--[[
local ls = require("luasnip")
vim.keymap.set({ "i", "s" }, "<M-l>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<M-h>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })
]]--

--[[
vim.keymap.set("i", "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
--]]
--[[
require("codecompanion").setup({
  display = {
    diff = {
      provider = "ollama",
    },
  },
  opts = {
    log_level = "DEBUG",
    system_prompt = "",
  },
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("openai_compatible", {
        schema = {
            model = {
                desc = "codellama:7b"
            }
        },
        env = {
          url = "http://localhost:11434", -- optional: default value is ollama url http://127.0.0.1:11434
          chat_url = "/v1/chat/completions", -- optional: default value, override if different
        },
      })
    end,
  },
    strategies = {
      cmd = {
          adapter = "ollama",
                model = {
                    desc = "codellama:7b"
                },
          opts = {
              system_prompt = "",
          },
      },
        chat = {
          adapter = "ollama",
            schema = {
                model = {
                    desc = "codellama:7b"
                }
            },
          opts = {
              system_prompt = ""
          }
        },
        inline = {
          adapter = "ollama",
        },
      },
})
]]
