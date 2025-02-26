local M = {}

function M.spell_correction()
    local word = vim.fn.expand('<cword>')
    local suggestions = vim.fn.spellsuggest(word)

    if #suggestions == 0 then
        vim.notify("No spelling suggestions found", vim.log.levels.WARN)
        return
    end

    -- Create suggestions window
    local suggestions_text = {}
    for i, suggestion in ipairs(suggestions) do
        table.insert(suggestions_text, string.format("%d. %s", i, suggestion))
    end

    -- Create actions window content (purely visual)
    local actions_text = {
        "Spell Actions:",
        "[a] Add to local dict",
        "[g] Add to global dict",
    }

    -- Calculate dimensions
    local suggestions_width = 0
    for _, line in ipairs(suggestions_text) do
        suggestions_width = math.max(suggestions_width, #line)
    end
    local actions_width = 0
    for _, line in ipairs(actions_text) do
        actions_width = math.max(actions_width, #line)
    end

    -- Create suggestions window
    local suggestions_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(suggestions_buf, 0, -1, false, suggestions_text)

    local suggestions_win = vim.api.nvim_open_win(suggestions_buf, true, {
        style = "minimal",
        relative = "cursor",
        width = suggestions_width,
        height = #suggestions_text,
        row = 1,
        col = 0,
        border = "rounded",
    })

    -- Create actions window (right of suggestions)
    local actions_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(actions_buf, 0, -1, false, actions_text)

    local actions_win = vim.api.nvim_open_win(actions_buf, false, {
        style = "minimal",
        relative = "win",
        win = suggestions_win,
        width = actions_width,
        height = #actions_text,
        row = 0,
        col = suggestions_width + 1, -- Place to the right of suggestions
        border = "rounded",
    })

    -- Configure both buffers
    for _, buf in ipairs({ suggestions_buf, actions_buf }) do
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'readonly', true)
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    end

    -- Set keymaps ONLY in suggestions window
    function M.close_windows()
        vim.api.nvim_win_close(suggestions_win, true)
        vim.api.nvim_win_close(actions_win, true)
    end

    -- Suggestion replacements
    for i = 1, #suggestions do
        vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', tostring(i), '', {
            callback = function()
                M.close_windows()
                vim.api.nvim_command('normal! ciw' .. suggestions[i])
            end,
            noremap = true,
            silent = true,
        })
    end

    -- Spell action handlers
    local actions = {
        a = { cmd = 'spellgood', msg = "Added to local dictionary" },
        b = { cmd = 'spellgood!', msg = "Added to global dictionary" },
    }

    for key, action in pairs(actions) do
        vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', key, '', {
            callback = function()
                M.close_windows()
                vim.cmd(action.cmd .. ' ' .. word)
                vim.notify(action.msg .. ": " .. word)
            end,
            noremap = true,
            silent = true,
        })
    end

    -- Close mappings for suggestions window
    local close_cmd = '<cmd>lua require("bufopt").spell.close_windows()<CR>'
    local settings = { noremap = true, silent = true }

    local function apply_under_cursor()
        local row = vim.api.nvim_win_get_cursor(suggestions_win)[1]
        M.close_windows()
        vim.api.nvim_command('normal! ciw' .. suggestions[row])
    end

    vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', '<M-;>', close_cmd, settings)
    vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', 'q', close_cmd, settings)
    vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', '<esc>', close_cmd, settings)

    vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', '<CR>', '', {
        callback = apply_under_cursor,
        noremap = true,
        silent = true
    })
    vim.api.nvim_buf_set_keymap(suggestions_buf, 'n', '<M-i>', '', {
        callback = apply_under_cursor,
        noremap = true,
        silent = true
    })

    -- Set highlights for actions window
    vim.api.nvim_buf_add_highlight(actions_buf, -1, 'Title', 0, 0, -1)
    for i = 1, 3 do
        vim.api.nvim_buf_add_highlight(actions_buf, -1, 'SpecialKey', i, 0, 3)
    end

    -- Keep focus in suggestions window
    vim.api.nvim_set_current_win(suggestions_win)
end

return M
