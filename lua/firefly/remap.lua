vim.g.mapleader = " "

vim.keymap.set("n", "<M-h>", "<C-w>h")
vim.keymap.set("n", "<M-j>", "<C-w>j")
vim.keymap.set("n", "<M-k>", "<C-w>k")
vim.keymap.set("n", "<M-l>", "<C-w>l")

vim.keymap.set("n", "<M-H>", "<C-w>H")
vim.keymap.set("n", "<M-J>", "<C-w>J")
vim.keymap.set("n", "<M-K>", "<C-w>K")
vim.keymap.set("n", "<M-L>", "<C-w>L")

vim.keymap.set("n", "<leader>w", "<C-w>")

-- fluent scrolling (lazy loaded - require cinnamon only when used)
local function cinnamon_scroll(cmd)
  return function()
    local ok, cinnamon = pcall(require, "cinnamon")
    if ok then
      cinnamon.scroll(cmd)
    else
      vim.cmd("normal! " .. vim.api.nvim_replace_termcodes(cmd, true, false, true))
    end
  end
end

vim.keymap.set("n", "<C-U>", cinnamon_scroll("<C-U>zz"))
vim.keymap.set("n", "<C-D>", cinnamon_scroll("<C-D>zz"))
vim.keymap.set("n", "<C-B>", cinnamon_scroll("<C-B>zz"))
vim.keymap.set("n", "<C-F>", cinnamon_scroll("<C-F>zz"))
vim.keymap.set("n", "n", cinnamon_scroll("nzz"))
vim.keymap.set("n", "N", cinnamon_scroll("Nzz"))
vim.keymap.set("n", "''", cinnamon_scroll("''zz"))

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

vim.keymap.set({
        'n',
        'i',
        'v',
        'c',
        'o',
        's',
        't',
        'x'
    }, '<M-i>', '<CR>',
    { noremap = true, silent = true
})



vim.keymap.set("n", "<leader>x", vim.cmd.Ex)

vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float() end)
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
--vim.keymap.set('n', '<leader>q', function () end)


-- Bufopt (lazy loaded)
vim.keymap.set('n', '<leader>m', function()
  local ok, bufoptts = pcall(require, "bufopt")
  if ok then
    bufoptts.open_floating_window()
  end
end, { noremap = true, silent = true })

vim.keymap.set('n', '<M-u>', function() vim.api.nvim_command('UndotreeToggle') end)
vim.keymap.set('n', '<leader><leader>', function()
  local telescope_state = require('firefly.plugins.telescope_state')
  local last_query, last_index = telescope_state.load_search("find_files")
  local selection_restored = false
  
  require('telescope.builtin').find_files({
    default_text = last_query or "",
    prompt_title = "Find Files" .. (last_query and " (last: " .. last_query .. ")" or ""),
    on_complete = last_index and {
      function(picker)
        if not selection_restored then
          selection_restored = true
          picker:set_selection(last_index)
        end
      end
    } or nil,
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
        if current_picker then
          local prompt = current_picker:_get_prompt()
          local selection_row = current_picker:get_selection_row()
          telescope_state.save_search("find_files", prompt, selection_row)
        end
        require("telescope.actions").select_default(prompt_bufnr)
      end)
      -- Clear state when closing Telescope
      map('i', '<Esc>', function()
        telescope_state.clear_search("find_files")
        require("telescope.actions").close(prompt_bufnr)
      end)
      return true
    end,
  })
end)
vim.keymap.set('n', '<leader>s', function()
  local telescope_state = require('firefly.plugins.telescope_state')
  local last_query, last_index = telescope_state.load_search("live_grep")
  local selection_restored = false
  
  require('telescope.builtin').live_grep({
    default_text = last_query or "",
    prompt_title = "Live Grep" .. (last_query and " (last: " .. last_query .. ")" or ""),
    on_complete = last_index and {
      function(picker)
        if not selection_restored then
          selection_restored = true
          picker:set_selection(last_index)
        end
      end
    } or nil,
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
        if current_picker then
          local prompt = current_picker:_get_prompt()
          local selection_row = current_picker:get_selection_row()
          telescope_state.save_search("live_grep", prompt, selection_row)
        end
        require("telescope.actions").select_default(prompt_bufnr)
      end)
      -- Clear state when closing Telescope
      map('i', '<Esc>', function()
        telescope_state.clear_search("live_grep")
        require("telescope.actions").close(prompt_bufnr)
      end)
      return true
    end,
  })
end)
--vim.keymap.set('n', '<leader>d', function() vim.lsp.buf.type_definition() end)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])


local function swap_lines(ln1, ln2)
    local readonly = vim.bo.readonly
    if not readonly then
        local l1 = vim.fn.getline(ln1)
        local l2 = vim.fn.getline(ln2)
        vim.fn.setline(ln1, l2)
        vim.fn.setline(ln2, l1)
    end
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

vim.keymap.set('n', '<C-k>', function()
    swap_up()
end)
vim.keymap.set('n', '<C-j>', function()
    swap_down()
end)
