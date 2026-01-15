local modes = {}

local function set_modes()
    local palette_module = require('firefly-theme.palette')
    local statusline = palette_module.get_statusline()
    local palette = palette_module.get()

    -- Get colors from statusline mappings
    local normal_bg = palette[statusline.normal]
    local visual_bg = palette[statusline.visual]
    local insert_bg = palette[statusline.insert]
    local replace_bg = palette[statusline.replace]
    local command_bg = palette[statusline.command]
    local terminal_bg = palette[statusline.terminal]
    local mode_fg = palette.bg1

    return {
        ['n']      = {mode = 'NM',  bg = normal_bg, fg = mode_fg},
        ['no']     = {mode = 'O-P', bg = normal_bg, fg = mode_fg},
        ['nov']    = {mode = 'O-P', bg = normal_bg, fg = mode_fg},
        ['noV']    = {mode = 'O-P', bg = normal_bg, fg = mode_fg},
        ['no\22']  = {mode = 'O-P', bg = normal_bg, fg = mode_fg},
        ['niI']    = {mode = 'NM',  bg = normal_bg, fg = mode_fg},
        ['niR']    = {mode = 'NM',  bg = normal_bg, fg = mode_fg},
        ['niV']    = {mode = 'NM',  bg = normal_bg, fg = mode_fg},
        ['nt']     = {mode = 'NM',  bg = normal_bg, fg = mode_fg},
        ['ntT']    = {mode = 'NM',  bg = normal_bg, fg = mode_fg},

        ['v']      = {mode = 'VM',  bg = visual_bg, fg = mode_fg},
        ['vs']     = {mode = 'VM',  bg = visual_bg, fg = mode_fg},
        ['V']      = {mode = 'V-L', bg = visual_bg, fg = mode_fg},
        ['Vs']     = {mode = 'V-L', bg = visual_bg, fg = mode_fg},
        ['\22']    = {mode = 'V-B', bg = visual_bg, fg = mode_fg},
        ['\22s']   = {mode = 'V-B', bg = visual_bg, fg = mode_fg},

        ['s']      = {mode = 'SLC', bg = visual_bg, fg = mode_fg},
        ['S']      = {mode = 'S-L', bg = visual_bg, fg = mode_fg},
        ['\19']    = {mode = 'S-B', bg = visual_bg, fg = mode_fg},

        ['i']      = {mode = 'IM', bg = insert_bg, fg = mode_fg},
        ['ic']     = {mode = 'IM', bg = insert_bg, fg = mode_fg},
        ['ix']     = {mode = 'IM', bg = insert_bg, fg = mode_fg},

        ['R']      = {mode = 'RM',  bg = replace_bg, fg = mode_fg},
        ['Rc']     = {mode = 'RM',  bg = replace_bg, fg = mode_fg},
        ['Rx']     = {mode = 'RM',  bg = replace_bg, fg = mode_fg},
        ['Rv']     = {mode = 'V-R', bg = replace_bg, fg = mode_fg},
        ['Rvc']    = {mode = 'V-R', bg = replace_bg, fg = mode_fg},
        ['Rvx']    = {mode = 'V-R', bg = replace_bg, fg = mode_fg},

        ['c']      = {mode = 'CM',  bg = command_bg, fg = mode_fg},
        ['cv']     = {mode = 'EX',  bg = command_bg, fg = mode_fg},
        ['ce']     = {mode = 'EX',  bg = command_bg, fg = mode_fg},
        ['!']      = {mode = 'SH',  bg = terminal_bg, fg = mode_fg},
        ['t']      = {mode = 'TM',  bg = terminal_bg, fg = mode_fg},

        ['r']      = {mode = 'RP',      bg = replace_bg, fg = mode_fg},
        ['rm']     = {mode = 'MORE',    bg = command_bg, fg = mode_fg},
        ['r?']     = {mode = 'CONFIRM', bg = command_bg, fg = mode_fg},
    }
end

function modes.get_modes()
    local editor_modes = set_modes()
    local mode_code = vim.api.nvim_get_mode().mode
    if editor_modes[mode_code].mode == nil then
        return mode_code
    end
    --vim.api.nvim_set_hl(0, 'stat_outer', { fg = palette.text, bg = mode_color })
    --vim.api.nvim_set_hl(0, 'stat_split_outer', { fg = mode_color, bg = "#2a3d33"})

    return {
        mode = editor_modes[mode_code].mode,
        color = {
            bg = editor_modes[mode_code].bg,
            fg = editor_modes[mode_code].fg
        }
    }
end

return modes;
