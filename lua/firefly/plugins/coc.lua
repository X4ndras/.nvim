--vim.cmd("CocInstall coc-json coc-css coc-sumneko-lua coc-rust-analyzer coc-tsserver coc-html coc-clangd coc-go coc-flutter")
vim.cmd [[ 
    highlight clear CocMenuSel 
    highlight! link CocMenuSel Search
]]

local keyset = vim.keymap.set

function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
-- Coc keymaps
-- select next
keyset("i", "<M-j>",
    'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<M-j>" : coc#refresh()', opts)
-- select prev
keyset("i", "<M-k>",
    [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
-- autocomplete
keyset("i", "<M-i>",
    [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

vim.g.coc_snippet_next = '<M-k>'
vim.g.coc_snippet_prev = '<M-j>'

keyset("n", "]]", "<Plug>(coc-diagnostic-next)", {silent = true})
keyset("n", "[[", "<Plug>(coc-diagnostic-prev)", {silent = true})

-- GoTo code navigation
keyset("n", "<leader>d", "<Plug>(coc-definition)", {silent = true})
--keyset("n", "<leader>t", "<Plug>(coc-type-definition)", {silent = true})
--keyset("n", "<leader>i", "<Plug>(coc-implementation)", {silent = true})
--keyset("n", "<leader>r", "<Plug>(coc-references)", {silent = true})

-- Symbol renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})

function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})

-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
---@diagnostic disable-next-line: redefined-local
local opts = {silent = true, nowait = true}
keyset("x", "<M-a>", "<Plug>(coc-codeaction-cursor)<CR>", opts)
keyset("n", "<M-a>", "<Plug>(coc-codeaction-selected)<CR>", opts)



-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = {silent = true, nowait = true, expr = true}
keyset("n", "<C-j>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<M-j>"', opts)
keyset("n", "<C-k>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<M-k>"', opts)
keyset("i", "<C-j>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-k>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-j>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<M-j>"', opts)
keyset("v", "<C-k>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<M-k>"', opts)
