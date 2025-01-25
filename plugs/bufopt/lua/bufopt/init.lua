local filecmds = require("bufopt.filecmds")

local M = {}

local function spell_correction()
    -- Get the list of spelling suggestions
    local suggestions = vim.fn.spellsuggest(vim.fn.expand('<cword>'))

    if #suggestions == 0 then
        vim.notify("No spelling suggestions found", vim.log.levels.WARN)
        return
    end

    -- Create a table to hold the text lines for the floating window
    local text = {}
    for i, suggestion in ipairs(suggestions) do
        table.insert(text, string.format("%d. %s", i, suggestion))
    end

    -- Calculate the width and height of the floating window
    local width = 0
    for _, line in ipairs(text) do
       width = math.max(width, #line)
    end
    local height = #text

    -- Define the options for the floating window
    local opts = {
        style = "minimal",
        relative = "cursor",
        width = width,
        height = height,
        row = 1,
        col = 0,
        border = "rounded",
    }

    -- Create the buffer and window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Make the buffer read-only and unmodifiable
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'SpellSuggest')

    -- Set key mappings for selecting a suggestion
    for i = 1, #suggestions do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                vim.api.nvim_win_close(win, true)
                vim.api.nvim_command('normal! ciw' .. suggestions[i])
            end,
            noremap = true,
            silent = true,
        })
    end

    -- Set key mappings to close the window
    local close_cmd = '<cmd>bd!<CR>'
    vim.api.nvim_buf_set_keymap(buf, 'n', '<M-;>', close_cmd, { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', close_cmd, { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', close_cmd, { nowait = true, noremap = true, silent = true })
end

-- Etwas interessantes is heute passiert
-- Define actions for normal buffers
local function hover()
   vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
       vim.lsp.handlers.hover, {
           -- Use a sharp border with `FloatBorder` highlights
           border = "rounded",
           max_width = 50,
           focusable = false,
           focus = false,
       }
   )
   vim.lsp.buf.hover()
end

vim.lsp.handlers["textDocument/codeAction"] = vim.lsp.with(
   vim.lsp.handlers.code_action, {
       -- Use a sharp border with `FloatBorder` highlights
       border = "rounded",
       max_width = 50,
       focusable = false,
       focus = false,
   }
)

M.normal_actions = {
    { name = "Rename Symbol",       fn = vim.lsp.buf.rename,         bind = 'R' },
    { name = "Show Signature Help", fn = vim.lsp.buf.signature_help, bind = 's' },
    { name = "Show References",     fn = vim.lsp.buf.references,     bind = 'r' },
    { name = "Show Quickfix",       fn = vim.lsp.buf.code_action,    bind = 'f' },
    { separator = true },
    { name = "Goto Definition",     fn = vim.lsp.buf.definition,     bind = 'gd' },
    { name = "Goto Declaration",    fn = vim.lsp.buf.declaration,    bind = 'gD' },
    { name = "Goto Implementation", fn = vim.lsp.buf.implementation, bind = 'gi' },
    { separator = true },
    { name = "Format Document",     fn = vim.lsp.buf.format,         bind = '<leader>F' },
    { name = "Hover Documentation", fn = hover,         bind = 'w' },
    { name = "Spell Correction",    fn = spell_correction,           bind = 'S' },
}

M.netrw_actions = {
    { name = "New Directory",       fn = filecmds.create_dir,       bind = 'd' },
    { name = "New File",            fn = filecmds.create_file,      bind = 'n' },
    { name = "Undo",                fn = filecmds.undo,             bind = 'u' },
    { separator = true },
    { name = "Open File",           fn = filecmds.open_file,        bind = 'o' },
    { name = "Preview File",        fn = M.open_file,               bind = 's' },
    { name = "Delete",              fn = filecmds.delete_path,      bind = 'D' },
    { name = "Rename File",         fn = filecmds.rename_file,      bind = 'r' },
    { separator = true },
    { name = "Copy File",           fn = filecmds.copy_file,        bind = 'c' },
    { name = "Cut File",            fn = filecmds.cut_file,         bind = 'x' },
    { name = "Paste File",          fn = filecmds.paste_file,       bind = 'p' },
    { separator = true },
    { name = "Open in Terminal",    fn = M.open_file,               bind = 't' },
}

-- Function to create a centered separator
function M.create_centered_separator(width, sep_char, sep_length)
    sep_char = sep_char or '='
    sep_length = sep_length or (width - 2)
    local padding = width - sep_length
    local left_padding = math.floor(padding / 2)
    local right_padding = padding - left_padding
    local sep_line = string.rep(' ', left_padding) .. string.rep(sep_char, sep_length) .. string.rep(' ', right_padding)
    return sep_line
end

-- Function to get actions based on the current buffer
local function get_actions()
    local ft = vim.bo.filetype
    if ft == 'netrw' then
        return M.netrw_actions
    else
        return M.normal_actions
    end
end


function M.open_floating_window()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local actions = get_actions()
    local text = {}
    local width = 0
    local bind_format = '[%s]'

    -- First generate the text lines and calculate the width
    for _, action in ipairs(actions) do
        if action.separator then
            -- We'll generate the separator lines after width is determined
        else
            local action_bind_format = action.bind_format or bind_format
            local bind_display = string.format(action_bind_format, action.bind)
            local line = string.format("%-24s %s", action.name, bind_display)
            width = math.max(width, #line)
            table.insert(text, line)
        end
    end

    -- Now that we have the width, generate the separator lines and pad other lines
    local processed_text = {}
    local text_idx = 1
    for _, action in ipairs(actions) do
        if action.separator then
            local line = M.create_centered_separator(width)
            table.insert(processed_text, line)
        else
            local line = text[text_idx]
            -- Pad the line to match the width
            if #line < width then
                line = line .. string.rep(' ', width - #line)
            end
            processed_text[#processed_text + 1] = line
            text_idx = text_idx + 1
        end
    end

    local height = #processed_text

    -- Now define M.opts with the calculated width and height
    M.opts = {
        style = "minimal",
        relative = "cursor",
        width = width,
        height = height,
        row = 1,
        col = 0,
        border = "rounded",
    }

    -- Create the buffer and window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, processed_text)
    local win = vim.api.nvim_open_win(buf, true, M.opts)

    -- Make the buffer read-only and unmodifiable
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'FloatingMenu')

    -- Define highlight groups with optional linking or specific colors
    local hl_groups = {
        FloatActionName = {
            fg = nil,
            bg = nil,
            bold = true,
            link = 'NvimOptionName',
        },
        FloatActionKey = {
            fg = nil,
            bg = nil,
            bold = true,
            link = 'Comment',
        },
        FloatSeparator = {
            fg = nil,
            bg = nil,
            bold = true,
            link = 'FloatBorder',
        },
    }

    -- Set the highlight groups
    for group, opts in pairs(hl_groups) do
        if opts.link then
            vim.api.nvim_set_hl(0, group, { link = opts.link })
        else
            vim.api.nvim_set_hl(0, group, {
                fg = opts.fg,
                bg = opts.bg,
                bold = opts.bold,
            })
        end
    end

    -- Set key mappings to close the window
    local close_cmd = '<cmd>bd!<CR>'
    vim.api.nvim_buf_set_keymap(buf, 'n', '<M-;>', close_cmd, { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', close_cmd, { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', close_cmd, { nowait = true, noremap = true, silent = true })

    -- Set key mappings and apply highlights for each action
    local line_nr = 0
    for _, action in ipairs(actions) do
        if action.separator then
            -- Apply highlight to the separator line
            vim.api.nvim_buf_add_highlight(buf, -1, 'FloatSeparator', line_nr, 0, -1)
        else
            local action_bind_format = action.bind_format or bind_format
            local bind_display = string.format(action_bind_format, action.bind)
            local line = processed_text[line_nr + 1]  -- Lua indexing starts at 1

            -- Calculate positions for highlighting
            local name_start = 0
            local name_end = #action.name
            local bind_start = #line - #bind_display
            local bind_end = #line

            -- Apply highlights
            vim.api.nvim_buf_add_highlight(buf, -1, 'FloatActionName', line_nr, name_start, name_end)
            vim.api.nvim_buf_add_highlight(buf, -1, 'FloatActionKey', line_nr, bind_start, bind_end)

            -- Set key mapping for the action
            vim.api.nvim_buf_set_keymap(buf, 'n', action.bind, '', {
                callback = function()
                    vim.api.nvim_win_close(win, true)
                    vim.api.nvim_win_set_cursor(0, cursor)
                    action.fn()
                end,
                noremap = true,
                silent = true,
            })
            text_idx = text_idx + 1
        end
        line_nr = line_nr + 1
    end
end


return M

