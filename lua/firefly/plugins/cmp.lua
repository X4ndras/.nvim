local cmp = require('cmp')
local luasnip = require("luasnip")
local lspkind = require('lspkind')

require("luasnip.loaders.from_vscode").lazy_load({})

require("luasnip").setup({
    history = true,
    delete_check_events = 'TextChanged',
})

cmp.setup({
    preselect = 'item',
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
        completion = {
            border = 'rounded',
            scrollbar = '║',
        },
        documentation = {
            border = 'rounded',
            scrollbar = '║',
        }
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.scroll_docs(4),
        ['<C-k>'] = cmp.mapping.scroll_docs(-4),
        ['<M-o>'] = cmp.mapping.abort(),
        ['<M-i>'] = cmp.mapping.confirm({ select = true }),
        ['<M-j>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif cmp.has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),

        ['<M-k>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        --['<C-e>'] = cmp.mapping.complete(),
        --['<C-i>'] = cmp.mapping.confirm({ select = true }), 
    }),
    sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
    }, {
        { name = 'buffer' },
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


-- autopairs setup
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)


-- Keymaps for Luasnip
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

--[[
vim.keymap.set("i", "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
--]]
