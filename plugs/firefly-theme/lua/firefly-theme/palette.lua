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
---@field bg0 string
---@field bg2 string
---@field bg1 string
---@field fg0 string
---@field fg1 string
---@field fg2 string
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
---@field color12 string
---@field color13 string
---@field color14 string
---@field color15 string
---@field color16 string
---@field color17 string
---@field none string

-- Store both colors and mappings
---@type PaletteColors
m.palette = {
  bg0 = '#21252b',     -- (nc) unfocued background
  bg1 = '#2c313a',     -- (surface) lighter background
  bg2 = '#353b45',     -- (overlay) selection/popup background

  color0 = '#282c34',  -- black (bg) main background
  color1 = '#e06c75',  -- red
  color2 = '#98c379',  -- green
  color3 = '#e5c07b',  -- yellow
  color4 = '#61afef',  -- blue
  color5 = '#c678dd',  -- magenta/purple
  color6 = '#56b6c2',  -- cyan
  color7 = '#b9bfca',  -- light gray

  color8 = '#5c6370',  -- dark gray/comment
  color9 = '#be5046',  -- bright red
  color10 = '#7ec16e', -- bright green
  color11 = '#d19a66', -- bright yellow/orange
  color12 = '#528bff', -- bright blue
  color13 = '#b267e6', -- bright magenta/purple
  color14 = '#41a6b5', -- bright cyan
  color15 = '#abb2bf', -- white (fg) main text

  color16 = '#d19a66', -- orange
  color17 = '#e5c07b', -- bright orange

  fg0 = '#dcdfe4',     -- foreground
  fg1 = '#9da5b4',     -- subtle
  fg2 = '#7f848e',     -- muted

  none = 'NONE',
}

-- Default mappings to use if none provided in JSON
m.mappings = {
  comment = "color8",    -- Dark gray
  keyword = "color5",    -- Magenta
  string = "color2",     -- Green
  number = "color11",    -- Bright Yellow
  variable = "color1",   -- Red
  fn = "color4",         -- Blue
  type = "color3",       -- Yellow
  class = "color3",      -- Yellow
  parameter = "color11", -- Bright Yellow
  operator = "color15",  -- White (fg)
  builtin = "color6",    -- Cyan
  property = "color1",   -- Red
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
    print("Error loading theme: invalid json")
    return nil
  end

  -- Handle the new JSON structure with colors and mappings
  if val.colors then
    m.palette = vim.tbl_deep_extend('force', m.palette, val.colors)
  else
    -- Legacy format - entire JSON is colors
    m.palette = vim.tbl_deep_extend('force', m.palette, val)
  end

  -- Store mappings if provided
  if val.mappings then
    m.mappings = vim.tbl_deep_extend('force', m.mappings, val.mappings)
  end

  return m.palette
end

-- Get the color for a specific syntax element using the mappings
function m.get_mapped_color(mapping_name)
  local color_key = m.mappings[mapping_name]
  if color_key and m.palette[color_key] then
    return m.palette[color_key]
  end
  return nil
end

function m.get()
  return m.palette
end

function m.get_mappings()
  return m.mappings
end

return m
