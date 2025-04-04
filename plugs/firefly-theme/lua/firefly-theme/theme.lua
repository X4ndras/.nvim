local statline = require('firefly-theme.statline')

---@class Highlight
---@field fg                string  | nil
---@field bg                string  | nil
---@field sp                string  | nil
---@field bold              boolean | nil
---@filed standout          boolean | nil
---@field underline         boolean | nil
---@field undercurl         boolean | nil
---@filed underdouble       boolean | nil
---@field underdotted       boolean | nil
---@field underdashed       boolean | nil
---@field strikethrough     boolean | nil
---@field italic            boolean | nil
---@field reverse           boolean | nil
---@field nocombine         boolean | nil
---@field link              string  | nil
---@field blend             number  | nil
---@field default           boolean | nil
---@field ctermfg           string  | nil
---@field ctermbg           string  | nil
---@field cterm             string  | nil
---@field force             boolean | nil

--- Function to blend two colors with a specified blend level (0-100)
--- color1: The base color (hex string like "#ff0000")
--- color2: The color to blend with (hex string like "#0000ff")
--- blend: Blend level from 0-100 (0 = fully color1, 100 = fully color2)
local function blend_colors(color1, color2, blend)
  -- Remove '#' if present
  color1 = color1:gsub("^#", "")
  color2 = color2:gsub("^#", "")

  -- Parse hex colors to RGB
  local r1 = tonumber(color1:sub(1, 2), 16)
  local g1 = tonumber(color1:sub(3, 4), 16)
  local b1 = tonumber(color1:sub(5, 6), 16)

  local r2 = tonumber(color2:sub(1, 2), 16)
  local g2 = tonumber(color2:sub(3, 4), 16)
  local b2 = tonumber(color2:sub(5, 6), 16)

  -- Calculate blend factor (0.0 - 1.0)
  local factor = blend / 100

  -- Linear interpolation between the colors
  local r = math.floor(r1 * (1 - factor) + r2 * factor)
  local g = math.floor(g1 * (1 - factor) + g2 * factor)
  local b = math.floor(b1 * (1 - factor) + b2 * factor)

  -- Ensure values are in valid range
  r = math.min(255, math.max(0, r))
  g = math.min(255, math.max(0, g))
  b = math.min(255, math.max(0, b))

  -- Convert back to hex
  return string.format("#%02x%02x%02x", r, g, b)
end

local m = {}

--loads the colorscheme
function m.load()
  local palette = require("firefly-theme.palette")
  local mappings = palette.get_mappings()
  palette = palette.get()

  vim.cmd('hi clear')
  vim.cmd('syntax reset')

  statline.setup()

  vim.opt.termguicolors    = true

  local option             = {
    -- either false or color
    base    = palette.bg0,
    surface = palette.bg1,
    italic  = true,
  }

  option.dim_nc_background = (false and palette.bg0) or option.base
  option.dim_nc_foreground = (false and palette.fg1) or palette.color15
  option.bold_vert_split   = (false and palette.color8) or palette.none

  local float_background   = palette.bg2

  ---@type table<string, Highlight>
  local theme              = {
    -------------------------------
    --          Nvim            --
    -------------------------------

    ['ColorColumn']                                     = { bg = palette.bg1 },
    ['Conceal']                                         = { bg = palette.none },

    --['CurSearch']         = { link = 'IncSearch' },
    --['Cursor']            = { fg = palette.color5, bg = palette.color4 },
    --['ICursor']           = {},
    --['CursorIM']          = {},
    --['CursorColumn']      = { bg = palette.color10 },
    --['CursorLine']        = { bg = palette.color10 },
    ['DarkenedPanel']                                   = { bg = option.surface },
    ['DarkenedStatusLine']                              = { bg = option.surface },

    ['Directory']                                       = { fg = palette.color5, bg = palette.none },
    ['DiffAdd']                                         = { bg = palette.color2, blend = 50 },
    ['DiffChange']                                      = { bg = palette.color3, blend = 50 },
    ['DiffDelete']                                      = { bg = palette.color1, blend = 50 },
    ['DiffText']                                        = { bg = palette.color3 },

    ['diffAdded']                                       = { link = 'DiffAdd' },
    ['diffChanged']                                     = { link = 'DiffChange' },
    ['diffRemoved']                                     = { link = 'DiffDelete' },

    --['EndOfBuffer']       = {},

    --['TermCursor']        = {},
    --['TermCursorNC']      = {},

    ['ErrorMsg']                                        = { fg = palette.color1, bold = true },
    ['Folded']                                          = { fg = palette.color15, bg = option.surface },
    ['FoldColumn']                                      = { fg = palette.fg2 },
    ['SignColumn']                                      = { fg = option.dim_nc_foreground, bg = option.base },
    ['IncSearch']                                       = { fg = palette.bg0, bg = palette.color2 },
    ['Substitute']                                      = { fg = palette.bg0, bg = palette.color2 },

    ['LineNr']                                          = { fg = palette.color15 },
    ['LineNrAbove']                                     = { fg = palette.fg2 },
    ['LineNrBelow']                                     = { fg = palette.fg2 },
    --['CursorLineNr']      = { fg = palette.text },
    --['CursorLineFold']    = {},
    --['CursorLineSign']    = {},

    --['MatchParen']        = { fg = palette.text, bg = palette.none },

    ['ModeMsg']                                         = { fg = palette.fg1 },
    -- ['MsgArea']          = {}
    -- ['MsgSeparator']     = {}
    ['MoreMsg']                                         = { fg = palette.color6 },
    ['NonText']                                         = { fg = palette.fg2 },

    ['Normal']                                          = { fg = palette.color15, bg = option.base },
    ['Normalfloat']                                     = { fg = palette.color15, bg = option.base },
    ['NormalNC']                                        = { fg = option.dim_nc_foreground, bg = option.dim_nc_background },
    ['NvimInternalError']                               = { fg = palette.color15, bg = palette.color1 },

    ['FloatBorder']                                     = { fg = palette.fg2, bg = option.surface },
    ['FloatTitle']                                      = { fg = palette.fg2 },
    --['FloatFooter']       = { },

    ['Pmenu']                                           = { fg = palette.fg1 },
    ['PmenuSel']                                        = { fg = palette.color15, bg = palette.bg2 },
    -- PmenuKind
    -- PmenuKindSel
    -- PmenuExtra
    -- PmenuExtraSel
    ['PmenuSbar']                                       = { bg = palette.color11 },
    ['PmenuThumb']                                      = { bg = palette.color8 },

    ['Question']                                        = { fg = palette.color2 },

    -- QuickFixLine
    ['RedrawDebugClear']                                = { fg = palette.color15, bg = palette.color2 },
    ['RedrawDebugComposed']                             = { fg = palette.color15, bg = palette.color4 },
    ['RedrawDebugRecompose']                            = { fg = palette.color15, bg = palette.color1 },
    ['Search']                                          = { fg = palette.bg0, bg = palette.color2 },
    ['SpecialKey']                                      = { fg = palette.color5 },
    ['SpellBad']                                        = { sp = palette.fg1, undercurl = true },
    ['SpellCap']                                        = { sp = palette.fg1, undercurl = true },
    ['SpellLocal']                                      = { sp = palette.fg1, undercurl = true },
    ['SpellRare']                                       = { sp = palette.fg1, undercurl = true },

    ['StatusLine']                                      = { fg = palette.fg2, bg = palette.bg0 },
    ['StatusLineNC']                                    = { fg = palette.fg2, bg = palette.bg0 },
    ['StatusLineTerm']                                  = { link = 'StatusLine' },
    ['StatusLineTermNC']                                = { link = 'StatusLineNC' },
    ['TabLine']                                         = { fg = palette.fg1, bg = palette.bg1 },
    ['TabLineFill']                                     = { bg = palette.bg1 },
    ['TabLineSel']                                      = { fg = palette.color15, bg = palette.bg2 },
    ['Title']                                           = { fg = palette.color15 },
    ['WinSeparator']                                    = { fg = palette.fg2, bg = option.bold_vert_split },

    ['Visual']                                          = { bg = palette.bg1 },
    -- VisualNOS
    ['WarningMSG']                                      = { fg = palette.color3 },
    -- WhiteSpace
    ['WildMenu']                                        = { link = 'IncSearch' },

    -- Syntax highlighting (these should use mappings)
    ['Boolean']                                         = { fg = palette[mappings.fn] },
    ['Character']                                       = { fg = palette[mappings.string] },
    ['Comment']                                         = { fg = palette[mappings.comment], italic = option.italic },
    ['Conditional']                                     = { fg = palette[mappings.variable] },
    ['Constant']                                        = { fg = palette[mappings.number] },
    ['Debug']                                           = { fg = palette[mappings.type] },
    ['Define']                                          = { fg = palette[mappings.keyword] },
    ['Delimiter']                                       = { fg = palette[mappings.operator] },
    ['Error']                                           = { fg = palette[mappings.variable] },
    ['Exception']                                       = { fg = palette[mappings.fn] },
    ['Float']                                           = { link = 'Number' },
    ['Function']                                        = { fg = palette[mappings.fn] },
    ['Identifier']                                      = { fg = palette[mappings.variable] }, -- variable
    -- Ignore = {},
    ['Include']                                         = { fg = palette[mappings.type] },
    ['Keyword']                                         = { fg = palette[mappings.keyword] },
    ['Label']                                           = { fg = palette[mappings.keyword] },
    ['Macro']                                           = { fg = palette[mappings.builtin] },
    ['Number']                                          = { fg = palette[mappings.number] },
    ['Operator']                                        = { fg = palette[mappings.operator] },
    ['PreCondit']                                       = { fg = palette[mappings.builtin] },
    ['PreProc']                                         = { fg = palette[mappings.string] },
    ['Repeat']                                          = { fg = palette[mappings.fn] },
    ['Special']                                         = { fg = palette[mappings.type] },
    ['SpecialChar']                                     = { fg = palette[mappings.type] },
    ['SpecialComment']                                  = { fg = palette[mappings.type] },
    ['Statement']                                       = { fg = palette[mappings.fn] },
    ['StorageClass']                                    = { fg = palette[mappings.type] },
    ['String']                                          = { fg = palette[mappings.string] },
    ['Structure']                                       = { fg = palette[mappings.keyword] },
    ['Tag']                                             = { fg = palette[mappings.keyword] },
    ['Todo']                                            = { fg = palette[mappings.builtin] },
    ['Type']                                            = { fg = palette[mappings.keyword] },
    ['Typedef']                                         = { link = 'Type' },
    ['Underlined']                                      = { underline = true },

    -- Diagnostics -- (using palette colors directly for UI elements)
    ['DiagnosticError']                                 = { fg = palette.color1 },
    ['DiagnosticHint']                                  = { fg = palette.color3 },
    ['DiagnosticInfo']                                  = { fg = palette.color5 },
    ['DiagnosticWarn']                                  = { fg = palette.color3 },
    ['DiagnosticDefaultError']                          = { link = 'DiagnosticError' },
    ['DiagnosticDefaultHint']                           = { link = 'DiagnosticHint' },
    ['DiagnosticDefaultInfo']                           = { link = 'DiagnosticInfo' },
    ['DiagnosticDefaultWarn']                           = { link = 'DiagnosticWarn' },
    ['DiagnosticFloatingError']                         = { link = 'DiagnosticError' },
    ['DiagnosticFloatingHint']                          = { link = 'DiagnosticHint' },
    ['DiagnosticFloatingInfo']                          = { link = 'DiagnosticInfo' },
    ['DiagnosticFloatingWarn']                          = { link = 'DiagnosticWarn' },
    ['DiagnosticSignError']                             = { link = 'DiagnosticError' },
    ['DiagnosticSignHint']                              = { link = 'DiagnosticHint' },
    ['DiagnosticSignInfo']                              = { link = 'DiagnosticInfo' },
    ['DiagnosticSignWarn']                              = { link = 'DiagnosticWarn' },
    ['DiagnosticStatusLineError']                       = { fg = palette.color1, bg = palette.bg1 },
    ['DiagnosticStatusLineHint']                        = { fg = palette.color3, bg = palette.bg1 },
    ['DiagnosticStatusLineInfo']                        = { fg = palette.color5, bg = palette.bg1 },
    ['DiagnosticStatusLineWarn']                        = { fg = palette.color3, bg = palette.bg1 },
    ['DiagnosticUnderlineError']                        = { fg = palette.color1, undercurl = true },
    ['DiagnosticUnderlineHint']                         = { fg = palette.color3, undercurl = true },
    ['DiagnosticUnderlineInfo']                         = { fg = palette.color5, undercurl = true },
    ['DiagnosticUnderlineWarn']                         = { fg = palette.color3, undercurl = true },
    ['DiagnosticVirtualTextError']                      = { link = 'DiagnosticError' },
    ['DiagnosticVirtualTextHint']                       = { link = 'DiagnosticHint' },
    ['DiagnosticVirtualTextInfo']                       = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualTextWarn']                       = { link = 'DiagnosticWarn' },

    -------------------------------
    --          Plugins          --
    -------------------------------

    --      hrsh7th/nvim-cmp    --
    ['GhostText']                                       = { fg = palette.color2, italic = option.italic },
    ['CmpItemAbbr']                                     = { fg = palette.fg1 },
    ['CmpItemAbbrDeprecated']                           = { fg = palette.fg1, strikethrough = true },
    ['CmpItemAbbrMatch']                                = { fg = palette.color15, bold = true },
    ['CmpItemAbbrMatchFuzzy']                           = { fg = palette.color15, bold = true },
    ['CmpItemKind']                                     = { fg = palette.fg1 },
    ['CmpItemKindClass']                                = { fg = palette[mappings.fn] },
    ['CmpItemKindFunction']                             = { fg = palette[mappings.fn] },
    ['CmpItemKindInterface']                            = { fg = palette[mappings.type] },
    ['CmpItemKindMethod']                               = { fg = palette[mappings.builtin] },
    ['CmpItemKindProperty']                             = { fg = palette[mappings.keyword] },
    ['CmpItemKindSnippet']                              = { fg = palette.fg1, italic = true },
    ['CmpItemKindVariable']                             = { link = '@variable' },

    --    MeanderingProgrammer/render-markdown  --
    -- ['RenderMarkdownH1']      = { bg = palette.color2, fg = "", bold = true },
    -- ['RenderMarkdownH2']      = { bg = palette.color1, fg = "", bold = true },
    -- ['RenderMarkdownH3']      = { bg = palette.color0, fg = "", bold = true },
    -- ['RenderMarkdownH4']      = { bg = palette.color0, fg = "", bold = true },
    -- ['RenderMarkdownH5']      = { bg = palette.color0, fg = "", bold = true },
    -- ['RenderMarkdownH6']      = { bg = palette.color0, fg = "", bold = true },
    ['RenderMarkdownH1Bg'] = { fg = palette.color6,  bg = palette.color6,  blend = 70, bold = true },
    ['RenderMarkdownH2Bg'] = { fg = palette.color11, bg = palette.color11, blend = 70, bold = true },
    ['RenderMarkdownH3Bg'] = { fg = palette.color2,  bg = palette.color2,  blend = 70, bold = true },
    ['RenderMarkdownH4Bg'] = { fg = palette.color10, bg = palette.color10, blend = 70, bold = true },
    ['RenderMarkdownH5Bg'] = { fg = palette.color5,  bg = palette.color5,  blend = 70, bold = true },
    ['RenderMarkdownH6Bg'] = { fg = palette.color13, bg = palette.color13, blend = 70, bold = true },
    ['@markup.link.label.markdown_inline'] = { fg = palette.color14 },

    --      nvim-treesitter/nvim-treesitter     --
    ['TreesitterContext']                               = { bg = palette.bg1, bold = true },
    ['TreesitterContextBottom']                         = { bg = option.surface, italic = option.italic },
    ['TreesitterContextLineNumber']                     = { bg = palette.bg1, bold = true, underline = true },
    ['TreesitterContextLineNumberBottom']               = { bg = palette.bg1, italic = option.italic },

    -- TS refactor highlighting
    ['TsDefinition']                                    = { bg = palette.fg0, fg = palette.bg0 },
    ['TsDefinitionUsage']                               = { bg = palette.fg0, fg = palette.bg0 },

    -- Treesitter tokens (these should use mappings)
    ['@punctuation.delimiter']                          = { link = "Delimiter" },
    ['@punctuation.bracket']                            = { fg = palette[mappings.operator] },
    ['@punctuation.special']                            = { fg = palette[mappings.operator] },
    ['@macro']                                          = { link = 'Macro' },
    ['@string']                                         = { link = 'String' },
    ['@string.special']                                 = { link = 'Special' },
    ['@function']                                       = { link = 'Function' },
    ['@function.builtin']                               = { link = 'Macro' },
    ['@parameter']                                      = { fg = palette[mappings.parameter], italic = option.italic },
    ['@method']                                         = { fg = palette[mappings.keyword] },
    ['@property']                                       = { fg = palette[mappings.keyword] },
    ['@constructor']                                    = { link = '@punctuation.bracket' },
    ['@conditional']                                    = { fg = palette[mappings.keyword] },
    ['@label']                                          = { fg = palette[mappings.type] },
    ['@operator']                                       = { link = 'Operator' },
    ['@keyword']                                        = { link = 'Keyword' },
    ['@keyword.coroutine']                              = { link = 'special' },
    ['@keyword.operator']                               = { fg = palette[mappings.fn] },
    ['@exception']                                      = { fg = palette[mappings.variable] },
    ['@variable']                                       = { fg = palette[mappings.variable] }, -- Fixed: using variable mapping, not string
    ['@variable.builtin']                               = { fg = palette[mappings.type] },
    ['@default.builtin']                                = { fg = palette[mappings.number] },
    ['@type']                                           = { link = 'Type' },
    ['@namespace']                                      = { fg = palette[mappings.builtin] },
    ['@symbol']                                         = { fg = palette[mappings.variable] },
    ['@interface']                                      = { fg = palette[mappings.type] },
    ['@tag']                                            = { fg = palette[mappings.keyword] },
    ['@tag.delimiter']                                  = { fg = palette[mappings.keyword] },
    ['@tag.attribute.html']                             = { fg = palette[mappings.type] },

    --      LSP Base     --
    ['@lsp.type.comment']                               = { link = "Comment" },
    ['@lsp.type.enum']                                  = { link = '@type' },
    ['@lsp.type.keyword']                               = { link = '@keyword' },
    ['@lsp.type.interface']                             = { link = '@interface' },
    ['@lsp.type.namespace']                             = { link = '@namespace' },
    ['@lsp.type.parameter']                             = { link = '@parameter' },
    ['@lsp.type.property']                              = { fg = palette[mappings.keyword] },
    ['@lsp.type.method']                                = {}, -- use treesitter styles for regular variable
    ['@lsp.type.variable']                              = { link = '@variable' },
    ['@lsp.typemod.function.defaultLibrary']            = { link = 'Special' },
    ['@lsp.typemod.variable.defaultLibrary']            = { link = '@variable.builtin' },

    -- LSP Injected Groups
    ['@lsp.typemod.operator.injected']                  = { link = '@operator' },
    ['@lsp.typemod.string.injected']                    = { link = '@string' },
    ['@lsp.typemod.variable.injected']                  = { link = '@variable' },

    --      nvim-telescope/telescope.nvim       --
    ['TelescopeBorder']                                 = { fg = palette.fg2, bg = palette.bg0 },
    ['TelescopeMatching']                               = { fg = palette.color2 },
    ['TelescopeNormal']                                 = { fg = palette.fg1, bg = float_background },
    ['TelescopePromptNormal']                           = { fg = palette.color15, bg = float_background },
    ['TelescopePromptPrefix']                           = { fg = palette.fg1 },
    ['TelescopeSelection']                              = { fg = palette.color5, bg = palette.bg1 },
    ['TelescopeSelectionCaret']                         = { fg = palette.color3, bg = palette.bg1 },
    ['TelescopeTitle']                                  = { fg = palette.fg1 },

    -------------------------------
    --    Language Overwrites    --
    -------------------------------

    --          lua              --
    ['@lsp.type.variable.lua']                          = { link = '' },
    ['@lsp.type.function.lua']                          = { link = '' },
    ['@lsp.type.property.lua']                          = { link = '' },
    ['@property.lua']                                   = { link = '' },
    ['@lsp.typemod.function.defaultLibrary.lua']        = { link = '' },
    ['@lsp.typemod.variable.defaultLibrary.lua']        = { link = '' },
    ['@keyword.coroutine.lua']                          = { link = 'Special' },

    --          rust            --
    ['@lsp.type.macro.rust']                            = { link = '@macro' },
    ['@keyword.modifier.rust']                          = { link = 'special' },
    ['@lsp.typemod.function.defaultLibrary.rust']       = { link = '@function' },

    --          golang          --
    ['@variable.member.go']                             = { link = '@property' },
    ['@module.go']                                      = { link = '@namespace' },
    ['@spell.go']                                       = {},

    --          c               --
    ['@keyword.import.c']                               = { link = '@namespace' },
    ['@lsp.type.macro.c']                               = { link = '@macro' },
    ['@lsp.typemod.function.defaultLibrary.c']          = { link = '@function' },

    --      javascript          --
    ['@tag.attribute.javascript']                       = { link = '@tag.attribute.html' },
    ['@variable.member.javascript']                     = { link = '@property' },
    ['@keyword.exception.javascript']                   = { fg = palette[mappings.variable] },
    ['@lsp.type.method.javascript']                     = { link = '@function' },
    ['@lsp.type.class.javascript']                      = { link = '@macro' },
    ['@constructor.javascript']                         = { link = '@macro' },
    ['@lsp.typemod.variable.defaultLibrary.javascript'] = { link = '@default.builtin' },
    ['@lsp.typemod.function.defaultLibrary.javascript'] = { link = '@function' },

    ['@lsp.type.class.typescript']                      = { link = '@macro' },
    ['@constructor.typescript']                         = { link = '@macro' },
    ['@lsp.typemod.variable.defaultLibrary.typescript'] = { link = '@default.builtin' },
    ['@lsp.typemod.function.defaultLibrary.typescript'] = { link = '@function' },
    ['@keyword.coroutine.typescript']                   = { link = 'Special' },

    ['@operator.css']                                   = { link = 'Special' },
    ['@keyword.directive.css']                          = { link = '@macro' },
    ['@tag.css']                                        = { fg = palette[mappings.variable] },
    ['@keyword.modifier.css']                           = { fg = palette[mappings.type], italic = true },

    --      python      --
    ['@variable.parameter.python']                      = { link = '@parameter' },
    ['@variable.member.python']                         = { link = '@property' },
    ['@constructor.python']                             = { link = '@macro' },
    ['@module.python']                                  = { link = '@namespace' },
    ['@attribute.builtin.python']                       = { fg = palette[mappings.number] },
    ['@type.python']                                    = { link = '@macro' }
  }

  -- Set terminal colors using ANSI colors directly from palette
  vim.g.terminal_color_0   = palette.color0
  vim.g.terminal_color_1   = palette.color1
  vim.g.terminal_color_2   = palette.color2
  vim.g.terminal_color_3   = palette.color3
  vim.g.terminal_color_4   = palette.color4
  vim.g.terminal_color_5   = palette.color5
  vim.g.terminal_color_6   = palette.color6
  vim.g.terminal_color_7   = palette.color7
  vim.g.terminal_color_8   = palette.color8
  vim.g.terminal_color_9   = palette.color9
  vim.g.terminal_color_10  = palette.color10
  vim.g.terminal_color_11  = palette.color11
  vim.g.terminal_color_12  = palette.color12
  vim.g.terminal_color_13  = palette.color13
  vim.g.terminal_color_14  = palette.color14
  vim.g.terminal_color_15  = palette.color15

  -- Set a highlight with a default priority
  local status, hooks      = pcall(require, 'ibl.hooks')
  if status then
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'high1', { fg = palette.bg1 })
    end)

    require('ibl').setup {
      indent = { highlight = { 'high1' }, char = '|' },
      scope  = { enabled = false }
      --scope = { highlight = { 'high2'} }
    }
  end

  for key, value in pairs(theme) do
    local fg = value.fg or 'none'
    local bg = value.bg or 'none'
    local sp = value.sp or 'none'
    if value.blend then
      -- if fg ~= 'none' then fg = blend_colors(fg, palette.bg0, value.blend) end
      if bg ~= 'none' then bg = blend_colors(bg, palette.bg0, value.blend) end
    end

    local values = vim.tbl_extend('force', value, { fg = fg, bg = bg, sp = sp })
    vim.api.nvim_set_hl(0, key, values)
  end
  vim.cmd('match Todo /TODO/')
end

return m
