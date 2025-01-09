local modes = {}

local function set_modes()
    local palette = require('firefly-theme.palette')
    palette = palette.get()

    return {
        ['n']      = {mode = 'NM',  bg = palette.color2, fg = palette.surface},
        ['no']     = {mode = 'O-P', bg = palette.color2, fg = palette.surface},
        ['nov']    = {mode = 'O-P', bg = palette.color2, fg = palette.surface},
        ['noV']    = {mode = 'O-P', bg = palette.color2, fg = palette.surface},
        ['no\22']  = {mode = 'O-P', bg = palette.color2, fg = palette.surface},
        ['niI']    = {mode = 'NM',  bg = palette.color2, fg = palette.surface},
        ['niR']    = {mode = 'NM',  bg = palette.color2, fg = palette.surface},
        ['niV']    = {mode = 'NM',  bg = palette.color2, fg = palette.surface},
        ['nt']     = {mode = 'NM',  bg = palette.color2, fg = palette.surface},
        ['ntT']    = {mode = 'NM',  bg = palette.color2, fg = palette.surface},

        ['v']      = {mode = 'VM',  bg = palette.color3, fg = palette.surface},
        ['vs']     = {mode = 'VM',  bg = palette.color3, fg = palette.surface},
        ['V']      = {mode = 'V-L', bg = palette.color3, fg = palette.surface},
        ['Vs']     = {mode = 'V-L', bg = palette.color3, fg = palette.surface},
        ['\22']    = {mode = 'V-B', bg = palette.color3, fg = palette.surface},
        ['\22s']   = {mode = 'V-B', bg = palette.color3, fg = palette.surface},

        ['s']      = {mode = 'SLC', bg = palette.base, fg = palette.surface},
        ['S']      = {mode = 'S-L', bg = palette.base, fg = palette.surface},
        ['\19']    = {mode = 'S-B', bg = palette.base, fg = palette.surface},

        ['i']      = {mode = 'IM', bg = palette.color1, fg = palette.text},
        ['ic']     = {mode = 'IM', bg = palette.color1, fg = palette.text},
        ['ix']     = {mode = 'IM', bg = palette.color1, fg = palette.text},

        ['R']      = {mode = 'RM',  bg = palette.color0, fg = palette.text},
        ['Rc']     = {mode = 'RM',  bg = palette.color0, fg = palette.text},
        ['Rx']     = {mode = 'RM',  bg = palette.color0, fg = palette.text},
        ['Rv']     = {mode = 'V-R', bg = palette.color0, fg = palette.text},
        ['Rvc']    = {mode = 'V-R', bg = palette.color0, fg = palette.text},
        ['Rvx']    = {mode = 'V-R', bg = palette.color0, fg = palette.text},

        ['c']      = {mode = ' ',  bg = palette.surface, fg = palette.text},
        ['cv']     = {mode = 'EX',  bg = palette.surface, fg = palette.text},
        ['ce']     = {mode = 'EX',  bg = palette.surface, fg = palette.text},
        ['!']      = {mode = '',   bg = palette.surface, fg = palette.text},
        ['t']      = {mode = '',   bg = palette.surface, fg = palette.text},

        ['r']      = {mode = 'RP',      bg = palette.base, fg = palette.surface},
        ['rm']     = {mode = 'MORE',    bg = palette.base, fg = palette.surface},
        ['r?']     = {mode = 'CONFIRM', bg = palette.base, fg = palette.surface},
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
