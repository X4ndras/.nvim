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

local function resolve_color(color_key, palette, mode_colors)
    if not color_key then
        return nil
    end

    if color_key == "mode_bg" then
        return mode_colors.bg
    end

    if color_key == "mode_fg" then
        return mode_colors.fg
    end

    if palette[color_key] then
        return palette[color_key]
    end

    return color_key
end

local function set_hl(mode_colors, palette)
    vim.api.nvim_set_hl(0, 'dgn',
        { fg = palette.bg1, bg = palette.bg0 })

    vim.api.nvim_set_hl(0, 'StatuslineMode',
        { fg = mode_colors.fg, bg = mode_colors.bg })
end

local function segment_text(segment, mode_info)
    if segment.type == "mode" then
        if segment.text then
            return segment.text:gsub("{mode}", mode_info.mode)
        end
        return mode_info.mode
    end

    if segment.type == "diagnostics" then
        return diagnostics()
    end

    if segment.type == "raw" then
        return segment.text or ""
    end

    return segment.text or ""
end

local function apply_highlight(segment, text, palette, mode_colors, index)
    if text == "" then
        return ""
    end

    if segment.type == "raw" or segment.type == "diagnostics" then
        return text
    end

    local fg = resolve_color(segment.fg, palette, mode_colors)
    local bg = resolve_color(segment.bg, palette, mode_colors)

    if not fg and not bg then
        return text
    end

    local group = string.format("StatuslineSegment%d", index)
    vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
    return string.format("%%#%s#%s", group, text)
end

local function build_statusline()
    local palette_module = require('firefly-theme.palette')
    local palette = palette_module.get()
    local layout = palette_module.get_statusline_layout() or {}
    local mode_info = modes.get_modes()
    local mode_colors = mode_info.color

    set_hl(mode_colors, palette)

    local statusline = ""
    for index, segment in ipairs(layout) do
        if segment.type == "align" then
            statusline = statusline .. "%="
        else
            local text = segment_text(segment, mode_info)
            statusline = statusline .. apply_highlight(segment, text, palette, mode_colors, index)
        end
    end

    return statusline
end

local function set_statusline()
    vim.wo.statusline = build_statusline()
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
        },
        { callback = set_statusline}
    )
    set_statusline()
end

m.setup()
return m
