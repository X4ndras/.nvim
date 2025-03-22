local modes = {}

local function set_modes()
    local palette = require('firefly-theme.palette')
    local mappings = palette.get_mappings()
    palette = palette.get()

    local normal_bg = palette[mappings.keyword]
    local visual_bg = palette[mappings.fn]
    local insert_bg = palette[mappings.class]
    local insert_fg = palette.bg1

    return {
        ['n']      = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},
        ['no']     = {mode = 'O-P', bg = normal_bg, fg = palette.bg1},
        ['nov']    = {mode = 'O-P', bg = normal_bg, fg = palette.bg1},
        ['noV']    = {mode = 'O-P', bg = normal_bg, fg = palette.bg1},
        ['no\22']  = {mode = 'O-P', bg = normal_bg, fg = palette.bg1},
        ['niI']    = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},
        ['niR']    = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},
        ['niV']    = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},
        ['nt']     = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},
        ['ntT']    = {mode = 'NM',  bg = normal_bg, fg = palette.bg1},

        ['v']      = {mode = 'VM',  bg = visual_bg, fg = palette.bg1},
        ['vs']     = {mode = 'VM',  bg = visual_bg, fg = palette.bg1},
        ['V']      = {mode = 'V-L', bg = visual_bg, fg = palette.bg1},
        ['Vs']     = {mode = 'V-L', bg = visual_bg, fg = palette.bg1},
        ['\22']    = {mode = 'V-B', bg = visual_bg, fg = palette.bg1},
        ['\22s']   = {mode = 'V-B', bg = visual_bg, fg = palette.bg1},

        ['s']      = {mode = 'SLC', bg = palette.bg0, fg = palette.bg1},
        ['S']      = {mode = 'S-L', bg = palette.bg0, fg = palette.bg1},
        ['\19']    = {mode = 'S-B', bg = palette.bg0, fg = palette.bg1},

        ['i']      = {mode = 'IM', bg = insert_bg, fg = insert_fg},
        ['ic']     = {mode = 'IM', bg = insert_bg, fg = insert_fg},
        ['ix']     = {mode = 'IM', bg = insert_bg, fg = insert_fg},

        ['R']      = {mode = 'RM',  bg = palette.color1, fg = palette.bg1},
        ['Rc']     = {mode = 'RM',  bg = palette.color1, fg = palette.bg1},
        ['Rx']     = {mode = 'RM',  bg = palette.color1, fg = palette.bg1},
        ['Rv']     = {mode = 'V-R', bg = palette.color1, fg = palette.bg1},
        ['Rvc']    = {mode = 'V-R', bg = palette.color1, fg = palette.bg1},
        ['Rvx']    = {mode = 'V-R', bg = palette.color1, fg = palette.bg1},

        ['c']      = {mode = ' ',  bg = palette.bg1, fg = palette.color15},
        ['cv']     = {mode = 'EX',  bg = palette.bg1, fg = palette.color15},
        ['ce']     = {mode = 'EX',  bg = palette.bg1, fg = palette.color15},
        ['!']      = {mode = '',   bg = palette.bg1, fg = palette.color15},
        ['t']      = {mode = '',   bg = palette.bg1, fg = palette.color15},

        ['r']      = {mode = 'RP',      bg = palette.bg0, fg = palette.bg1},
        ['rm']     = {mode = 'MORE',    bg = palette.bg0, fg = palette.bg1},
        ['r?']     = {mode = 'CONFIRM', bg = palette.bg0, fg = palette.bg1},
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
