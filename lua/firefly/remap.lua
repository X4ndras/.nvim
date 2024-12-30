vim.g.mapleader = " "

-- fluent scrolling
local cinnamon = require("cinnamon")
cinnamon.setup()

vim.keymap.set("n", "<C-U>", function() cinnamon.scroll("<C-U>zz") end)
vim.keymap.set("n", "<C-D>", function() cinnamon.scroll("<C-D>zz") end)
vim.keymap.set("n", "<C-B>", function() cinnamon.scroll("<C-B>zz") end)
vim.keymap.set("n", "<C-F>", function() cinnamon.scroll("<C-F>zz") end)
vim.keymap.set("n", "n", function() cinnamon.scroll("nzz") end)
vim.keymap.set("n", "N", function() cinnamon.scroll("Nzz") end)
vim.keymap.set("n", "''", function() cinnamon.scroll("''zz") end)

vim.keymap.set({
        'n',
        'i',
        'v',
        'c',
        'o',
        's',
        't',
        'x'
    }, '<M-;>', '<ESC>',
    { noremap = true, silent = true
})

--[[
vim.cmd.nnoremap("<M-;>", "<ESC>")
vim.cmd.inoremap("<M-;>", "<ESC>")
vim.cmd.vnoremap("<M-;>", "<ESC>")
vim.cmd.cnoremap("<M-;>", "<ESC>")
vim.api.nvim_set_keymap('o', '<M-;>', '<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('s', '<M-;>', '<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<M-;>', '<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<M-;>', '<ESC>', { noremap = true, silent = true })
]]--

vim.keymap.set("n", "<leader>x", vim.cmd.Ex)

vim.keymap.set('n', '<leader>i', function ()
   vim.lsp.buf.signature_help()
   vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
       vim.lsp.handlers.signature_help, {
           -- Use a sharp border with `FloatBorder` highlights
           border = "rounded",
           --max_height = 6,
           focusable = false,
           focus = false,
       }
   )
end)

vim.keymap.set('n', '<M-y>', function() vim.api.nvim_command('UndotreeToggle') end)
vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float() end)

vim.keymap.set('n', '<leader><leader>', function() vim.cmd('Telescope find_files') end)
vim.keymap.set('n', '<leader>s', function() vim.cmd('Telescope live_grep') end)

vim.keymap.set('n', '<leader>d', function() vim.lsp.buf.type_definition() end)

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])


-- moving line up down alt + jk
-- https://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim
local function swap_lines(ln1, ln2)
    local l1 = vim.fn.getline(ln1)
    local l2 = vim.fn.getline(ln2)
    vim.fn.setline(ln1, l2)
    vim.fn.setline(ln2, l1)
end

local function swap_up()
    local ln = vim.fn.line('.')
    if ln == 1 then
        return
    end
    swap_lines(ln, ln - 1)
    vim.cmd('exec ' .. ln .. ' - 1')
end

local function swap_down()
    local ln = vim.fn.line('.')
    if ln == vim.fn.line('$') then
        return
    end

    swap_lines(ln, ln + 1)
    vim.cmd('exec ' .. ln .. ' + 1')
end

vim.keymap.set('n', '<M-k>', function() swap_up() end)
vim.keymap.set('n', '<M-j>', function() swap_down() end)
