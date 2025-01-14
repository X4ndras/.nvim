--// #BD5644
--// #A64B3A 
--// #6A2F25

--// #E0A3A6
--// #d68589 
--// #CC666B

--// #888198
--// #625C70 
--// #45404F

--// #F1D6AB 
--// #E7AE64
--// #D48B1D

--// #E3DEDE
--// #CAC2C2
--// #978787

--// #2B2B28
--// #171512
--// #0F0E0F -- normal bg

--// #06060b -- box shadow

local m = {}

---@class PaletteColors
---@field nc string
---@field base string
---@field overlay string
---@field surface string
---@field muted string
---@field subtle string
---@field text string
---@field color0 string
---@field color1 string
---@field color2 string
---@field color3 string
---@field color4 string
---@field color5 string
---@field color6 string
---@field color7 string
---@field color8 string
---@field color9 string
---@field color10 string
---@field color11 string
---@field visual string
---@field none string

---@type PaletteColors
m.palette = {
    nc =        '#06060b',

    base =      '#0F0E0F',
    overlay =   '#161616',
    surface =   '#2B2B28',

    muted =     '#978787',
    subtle =    '#CAC2C2',
    text =      '#E3DEDE',

    color0 =    '#BD5644',
    color1 =    '#E0A3A6',
    color2 =    '#F1D6AB',
    visual =    '#f8ead3',
    color3 =    '#888198',

    color4 =    '#A64B3A',
    color5 =    '#CC666B',
    color6 =    '#D48B1D',
    color7 =    '#625C70',

    color8 =    '#b5e5b9',
    color9 =    '#A1CCD1',
    color10 =   '#91b794',
    color11 =   '#79999d',

    none = 'NONE',
}

---@param path string
function m.read_theme(path)
    local file, err = io.open(path, 'r')
    if not file then
        print("Error loading file: " .. tostring(err))
        return nil
    end

    local content = file:read("*all")
    file:close()

    local val = vim.json.decode(content)
    if not val then
        print("Error loading theme invalid json")
        return nil
    end

    --[[
    for k, v in pairs(val) do
        print(k .. ": " ..v)
    end
    ]]-- 

    m.palette = vim.tbl_deep_extend('force', m.palette, val)
    return m.palette
end

function m.get()
    return m.palette
end

return m

