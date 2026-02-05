local m = {}

-- Theme metadata
m.name = "Default"
m.description = "Default One Dark inspired theme"
m.variant = "dark" -- "dark" or "light"

---@class PaletteColors
---@field bg0 string
---@field bg2 string
---@field bg1 string
---@field fg0 string
---@field fg1 string
---@field fg2 string
---@field float_bg string|nil
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
  float_bg = nil,      -- (float) popup/float background, falls back to bg2

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

-- Default diagnostic color mappings
m.diagnostics = {
  error = "color9",      -- Bright red
  warning = "color17",   -- Bright orange/yellow
  info = "color4",       -- Blue
  hint = "color6",       -- Cyan
  ok = "color2",         -- Green
}

-- Default statusline mode color mappings
m.statusline = {
  normal = "color5",     -- Magenta (keyword color)
  insert = "color3",     -- Yellow (class color)
  visual = "color4",     -- Blue (fn color)
  replace = "color1",    -- Red
  command = "color6",    -- Cyan
  terminal = "color2",   -- Green
}

m.statusline_layout = {
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
  { type = "mode", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "%<%f %-3.(%h%m%r%)", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "%{&fileencoding}", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "align" },
  { type = "raw", text = "%#dgn#" },
  { type = "diagnostics" },
  { type = "raw", text = "%#dgn#" },
  { type = "align" },
  { type = "text", text = "          ", fg = "mode_fg", bg = "bg0" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "%-6.(%l/%v%)", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "%-5.(%p%% %)", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "", fg = "mode_bg", bg = "bg0" },
  { type = "text", text = "%P", fg = "mode_fg", bg = "mode_bg" },
  { type = "text", text = " ", fg = "mode_bg", bg = "bg0" },
}

local function read_json_file(path)
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

  return val
end

local function apply_theme_data(val, is_primary)
  if not val then
    return
  end

  if is_primary then
    if val.name then
      m.name = val.name
    end
    if val.description then
      m.description = val.description
    end
    if val.variant then
      m.variant = val.variant
    end
  end

  if val.colors then
    m.palette = vim.tbl_deep_extend('force', m.palette, val.colors)
  elseif val.color0 or val.bg0 then
    m.palette = vim.tbl_deep_extend('force', m.palette, val)
  end

  if val.mappings then
    m.mappings = vim.tbl_deep_extend('force', m.mappings, val.mappings)
  end

  if val.diagnostics then
    m.diagnostics = vim.tbl_deep_extend('force', m.diagnostics, val.diagnostics)
  end

  if val.statusline then
    local statusline_data = val.statusline
    if statusline_data.modes then
      m.statusline = vim.tbl_deep_extend('force', m.statusline, statusline_data.modes)
    elseif statusline_data.normal then
      m.statusline = vim.tbl_deep_extend('force', m.statusline, statusline_data)
    end

    if statusline_data.layout then
      m.statusline_layout = statusline_data.layout
    end
  end
end

---@param path string
function m.read_theme(path)
  local val = read_json_file(path)
  if not val then
    return nil
  end

  local dir = path:match("(.+)/[^/]+$") or "."
  if type(val.imports) == "table" then
    for _, import_name in ipairs(val.imports) do
      if type(import_name) == "string" then
        local import_path = string.format("%s/%s", dir, import_name)
        local import_data = read_json_file(import_path)
        apply_theme_data(import_data, false)
      end
    end
  end

  apply_theme_data(val, true)

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

function m.get_diagnostics()
  return m.diagnostics
end

function m.get_statusline()
  return m.statusline
end

function m.get_statusline_layout()
  return m.statusline_layout
end

function m.get_variant()
  return m.variant
end

function m.get_float_bg()
  return m.palette.float_bg or m.palette.bg2
end

function m.get_info()
  return {
    name = m.name,
    description = m.description,
    variant = m.variant,
  }
end

return m
