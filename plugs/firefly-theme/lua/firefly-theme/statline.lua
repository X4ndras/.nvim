local m = {}

local modes = require('firefly-theme.modes')

local function count_diagnostics(type, count)
    for _ , _ in pairs(type) do
        count =  count + 1
    end
    return count
end

local function diagnostics()
    local warnings  = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN });
    local errors    = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR });
    local infos     = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO });
    local hints     = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT });

    local types = {
        ['errors']      = {type = errors, count = 0},
        ['warnings']    = {type = warnings, count = 0},
        ['infos']       = {type = infos, count = 0},
        ['hints']       = {type = hints, count = 0}
    }

    for _, type_count in pairs(types) do
        type_count.count = count_diagnostics(type_count.type, type_count.count)
    end

    local diagnostic =
        '%#DiagnosticStatusLineInfo# ' .. types['infos'].count ..
        '%#DiagnosticStatusLineHint# 󰌵 ' .. types['hints'].count ..
        '%#DiagnosticStatusLineWarn#  ' .. types['warnings'].count ..
        '%#DiagnosticStatusLineError#  ' .. types['errors'].count

    return diagnostic
end

local function set_hl()
    local palette = require('firefly-theme.palette')
    palette = palette.get()

    vim.api.nvim_set_hl(0, 'isle',
        { fg = modes.get_modes().color.fg, bg = modes.get_modes().color.bg })

    vim.api.nvim_set_hl(0, 'isle_ends',
        { fg = modes.get_modes().color.bg , bg = palette.bg0 })

    vim.api.nvim_set_hl(0, 'dgn',
        { fg = palette.bg1, bg = palette.bg0 })
end

local function set_statusline()
    set_hl()
    vim.wo.statusline = '%#isle_ends#'
        .. ' %#isle#' .. modes.get_modes().mode .. '%#isle_ends#'
        .. ' %#isle#%<%f %-3.(%h%m%r%)%#isle_ends# '
        .. '%#isle#' .. vim.bo.fileencoding .. '%#isle_ends#'
        .. '%='
        .. '%#dgn#' .. diagnostics() .. '%#dgn#%#isle_ends#'
        .. '%='
        -- Center the diagnostics about 20 chars / 2 (no double digets)
        .. string.rep(' ', 10)
        .. '%#isle#%-6.('
        .. '%l/%v%)%#isle_ends# '
        .. '%#isle#%-5.(%p%% %)%#isle_ends# '
        .. '%#isle#%P%#isle_ends# '
end

function m.setup()
    vim.api.nvim_create_autocmd({
        'WinEnter',
        'ModeChanged',
        'BufLeave',
        'BufEnter',
        'CmdlineEnter',
        'CmdlineLeave',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        --'CursorMoved',
        --'CursorMovedI'
        },
        { callback = set_statusline}
    )
    set_statusline()
end

m.setup()
return m
