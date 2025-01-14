local statline = require('firefly-theme.statline')

---@class Highlight
---@field fg                string  | nil
---@field bg                string  | nil
---@field sp                string  | nil
---@field blend             number  | nil
---@field link              string  | nil
---@field italic            boolean | nil
---@field bold              boolean | nil
---@field strikethrough     boolean | nil
---@field undercurl         boolean | nil

local m = {}

--loads the colorscheme
function m.load()
    local palette = require("firefly-theme.palette")
    palette = palette.get()

    vim.cmd('hi clear')
    vim.cmd('syntax reset')

    statline.setup()

    vim.opt.termguicolors = true

    local option = {
        -- either false or color
        base = palette.base,
        surface = palette.surface,
        italic = true,
    }
    option.dim_nc_background = (
        false and palette.nc
    ) or option.base
    option.dim_nc_foreground = (
        false and palette.subtle
    ) or palette.text
    option.bold_vert_split = (
        false and palette.color8
    ) or palette.none

    local float_background = palette.overlay

    ---@type table<string, Highlight>
    local theme = {
        -------------------------------
        --          Nvim            --
        -------------------------------

        ['ColorColumn'] = { bg = palette.surface },
        ['Conceal'] = { bg = palette.none },

        --['CurSearch'] = { link = 'IncSearch' },
        --['Cursor'] = { fg = palette.color1, bg = palette.color4 },
        --['ICursor'] = {},
        --['CursorIM'] = {},
        --['CursorColumn'] = { bg = palette.color10 },
        --['CursorLine'] = { bg = palette.color10 },
        ['DarkenedPanel'] = { bg = option.surface },
        ['DarkenedStatusLine'] = { bg = option.surface },

        ['Directory'] = { fg = palette.color5, bg = palette.none },
        ['DiffAdd'] = { bg = palette.color5, blend = 20 },
        ['DiffChange'] = { bg = palette.overlay },
        ['DiffDelete'] = { bg = palette.color0 },
        ['DiffText'] = { bg = palette.color3 },

        ['diffAdded'] = { link = 'DiffAdd' },
        ['diffChanged'] = { link = 'DiffChange' },
        ['diffRemoved'] = { link = 'DiffDelete' },

        --['EndOfBuffer'] = {},

        --['TermCursor'] = {},
        --['TermCursorNC'] = {},

        ['ErrorMsg'] = { fg = palette.color0, bold = true},
        ['Folded'] = { fg = palette.text, bg = option.surface },
        ['FoldColumn'] = { fg = palette.muted },
        ['SignColumn'] = {
            fg = option.dim_nc_foreground,
            bg = option.base
        },
        ['IncSearch'] = { fg = palette.base, bg = palette.color2 },
        ['Substitute'] = { fg = palette.base, bg = palette.color2 },

        ['LineNr'] = { fg = palette.text },
        ['LineNrAbove'] = { fg = palette.muted },
        ['LineNrBelow'] = { fg = palette.muted },
        --['CursorLineNr'] = { fg = palette.text },
        --['CursorLineFold'] = {},
        --['CursorLineSign'] = {},

        --['MatchParen'] = { fg = palette.text, bg = palette.none },

        ['ModeMsg'] = { fg = palette.subtle },
        -- ['MsgArea'] = {}
        -- ['MsgSeparator'] = {}
        ['MoreMsg'] = { fg = palette.color6 },
        ['NonText'] = { fg = palette.muted },

        ['Normal'] = { fg = palette.text, bg = option.base },
        ['Normalfloat'] = { fg = palette.text, bg = option.base },
        ['NormalNC'] = { fg = option.dim_nc_foreground, bg = option.dim_nc_background },
        ['NvimInternalError'] = { fg = palette.text, bg = palette.color0 },


        ['FloatBorder'] = { fg = palette.muted, bg = option.overlay },
        ['FloatTitle'] = { fg = palette.muted },
        --['FloatFooter'] = { },


        ['Pmenu'] = { fg = palette.subtle },
        ['PmenuSel'] = { fg = palette.text, bg = palette.overlay },
        -- PmenuKind
        -- PmenuKindSel
        -- PmenuExtra
        -- PmenuExtraSel
        ['PmenuSbar'] = { bg = palette.color9 },
        ['PmenuThumb'] = { bg = palette.color8 },

        ['Question'] = { fg = palette.color2 },

        -- QuickFixLine
        ['RedrawDebugClear'] = { fg = palette.text, bg = palette.color2 },
        ['RedrawDebugComposed'] = { fg = palette.text, bg = palette.color4 },
        ['RedrawDebugRecompose'] = { fg = palette.text, bg = palette.color0 },
        ['Search'] = { fg = palette.base, bg = palette.color2 },
        ['SpecialKey'] = { fg = palette.color5 },
        ['SpellBad'] = { sp = palette.subtle, undercurl = true },
        ['SpellCap'] = { sp = palette.subtle, undercurl = true },
        ['SpellLocal'] = { sp = palette.subtle, undercurl = true },
        ['SpellRare'] = { sp = palette.subtle, undercurl = true },

        ['StatusLine'] = { fg = palette.muted, bg = palette.base },
        ['StatusLineNC'] = { fg = palette.muted, bg = palette.base },
        ['StatusLineTerm'] = { link = 'StatusLine'},
        ['StatusLineTermNC'] = { link = 'StatusLineNC'},
        ['TabLine'] = {fg = palette.subtle, bg = palette.surface },
        ['TabLineFill'] = { bg = palette.surface },
        ['TabLineSel'] = { fg = palette.text, bg = palette.overlay },
        ['Title'] = { fg = palette.text },
        ['WinSeparator'] = { fg = palette.muted, bg = option.bold_vert_split },

        ['Visual'] = { bg = palette.surface },
        -- VisualNOS
        ['WarningMSG'] = { fg = palette.color2 },
        -- WhiteSpace
        ['WildMenu'] = { link = 'IncSearch' },

        ['Boolean'] = { fg = palette.color4 },
		    ['Character'] = { fg = palette.color2 },
            -- This is a comment
		    ['Comment'] = { fg = palette.muted, italic = option.italic },
		    ['Conditional'] = { fg = palette.color0 },
		    ['Constant'] = { fg = palette.color11 },
		    ['Debug'] = { fg = palette.color3 },
		    ['Define'] = { fg = palette.color1 },
		    ['Delimiter'] = { fg = palette.subtle },
		    ['Error'] = { fg = palette.color0 },
		    ['Exception'] = { fg = palette.color4 },
		    ['Float'] = { link = 'Number' },
		    ['Function'] = { fg = palette.color4 },
		    ['Identifier'] = { fg = palette.color2 },
		    -- Ignore = {},
		    ['Include'] = { fg = palette.color3 },
		    ['Keyword'] = { fg = palette.color1 },
		    ['Label'] = { fg = palette.color5 },
		    ['Macro'] = { fg = palette.color6 },
		    ['Number'] = { fg = palette.color11 },
		    ['Operator'] = { fg = palette.subtle },
		    ['PreCondit'] = { fg = palette.color6 },
		    ['PreProc'] = { fg = palette.color2 },
		    ['Repeat'] = { fg = palette.color4 },
		    ['Special'] = { fg = palette.color3 },
		    ['SpecialChar'] = { fg = palette.color3 },
		    ['SpecialComment'] = { fg = palette.color3 },
		    ['Statement'] = { fg = palette.color4 },
		    ['StorageClass'] = { fg = palette.color3 },
		    ['String'] = { fg = palette.color10},
		    ['Structure'] = { fg = palette.color5 },
		    ['Tag'] = { fg = palette.color5 },
		    ['Todo'] = { fg = palette.color6 },
		    ['Type'] = { fg = palette.color5 },
		    ['Typedef'] = { link = 'Type' },
		    ['Underlined'] = { underline = true },

            --[[
		    ['htmlArg'] = { fg = palette.color6 },
		    ['htmlBold'] = { bold = true },
		    ['htmlEndTag'] = { fg = palette.subtle },
		    ['htmlH1'] = { fg = palette.color6 },
		    ['htmlH2'] = { fg = palette.color5 },
		    ['htmlH3'] = { fg = palette.color3 },
		    ['htmlH4'] = { fg = palette.color2 },
		    ['htmlH5'] = { fg = palette.color4 },
		    ['htmlItalic'] = { italic = option.italic },
		    ['htmlLink'] = { fg = palette.color6 },
		    ['htmlTag'] = { fg = palette.subtle },
		    ['htmlTagN'] = { fg = palette.text },
		    ['htmlTagName'] = { fg = palette.color5 },

		    ['markdownDelimiter'] = { fg = palette.subtle },
		    ['markdownH1'] = { fg = palette.color6, bold = true },
		    ['markdownH1Delimiter'] = { link = 'markdownH1' },
		    ['markdownH2'] = { fg = palette.color5, bold = true },
		    ['markdownH2Delimiter'] = { link = 'markdownH2' },
		    ['markdownH3'] = { fg = palette.color3, bold = true },
		    ['markdownH3Delimiter'] = { link = 'markdownH3' },
		    ['markdownH4'] = { fg = palette.color2, bold = true },
		    ['markdownH4Delimiter'] = { link = 'markdownH4' },
		    ['markdownH5'] = { fg = palette.color4, bold = true },
		    ['markdownH5Delimiter'] = { link = 'markdownH5' },
		    ['markdownH6'] = { fg = palette.color5, bold = true },
		    ['markdownH6Delimiter'] = { link = 'markdownH6' },
		    ['markdownLinkText'] = { fg = palette.color6, sp = palette.color6, underline = true },
		    ['markdownUrl'] = { link = 'markdownLinkText' },

		    ['mkdCode'] = { fg = palette.color5, italic = option.italic },
		    ['mkdCodeDelimiter'] = { fg = palette.color3 },
		    ['mkdCodeEnd'] = { fg = palette.color5 },
		    ['mkdCodeStart'] = { fg = palette.color5 },
		    ['mkdFootnotes'] = { fg = palette.color5 },
		    ['mkdID'] = { fg = palette.color5, underline = true },
		    ['mkdInlineURL'] = { fg = palette.color6 },
		    ['mkdLink'] = { link = 'mkdInlineURL' },
		    ['mkdLinkDef'] = { link = 'mkdInlineURL' },
		    ['mkdListItemLine'] = { fg = palette.text },
		    ['mkdRule'] = { fg = palette.subtle },
		    ['mkdURL'] = { link = 'mkdInlineURL' },
            ]]--

		    ['DiagnosticError'] = { fg = palette.color0 },
		    ['DiagnosticHint'] = { fg = palette.color3 },
		    ['DiagnosticInfo'] = { fg = palette.color1 },
		    ['DiagnosticWarn'] = { fg = palette.color2 },
		    ['DiagnosticDefaultError'] = { link = 'DiagnosticError' },
		    ['DiagnosticDefaultHint'] = { link = 'DiagnosticHint' },
		    ['DiagnosticDefaultInfo'] = { link = 'DiagnosticInfo' },
		    ['DiagnosticDefaultWarn'] = { link = 'DiagnosticWarn' },
		    ['DiagnosticFloatingError'] = { link = 'DiagnosticError' },
		    ['DiagnosticFloatingHint'] = { link = 'DiagnosticHint' },
		    ['DiagnosticFloatingInfo'] = { link = 'DiagnosticInfo' },
		    ['DiagnosticFloatingWarn'] = { link = 'DiagnosticWarn' },
		    ['DiagnosticSignError'] = { link = 'DiagnosticError' },
		    ['DiagnosticSignHint'] = { link = 'DiagnosticHint' },
		    ['DiagnosticSignInfo'] = { link = 'DiagnosticInfo' },
		    ['DiagnosticSignWarn'] = { link = 'DiagnosticWarn' },
		    ['DiagnosticStatusLineError'] = { fg = palette.color0, bg = palette.surface},
		    ['DiagnosticStatusLineHint'] = { fg = palette.color3, bg = palette.surface},
		    ['DiagnosticStatusLineInfo'] = { fg = palette.color1, bg = palette.surface},
		    ['DiagnosticStatusLineWarn'] = { fg = palette.color2, bg = palette.surface},
		    ['DiagnosticUnderlineError'] = { fg = palette.color0, undercurl = true },
		    ['DiagnosticUnderlineHint'] = { fg = palette.color3, undercurl = true },
		    ['DiagnosticUnderlineInfo'] = { fg = palette.color1, undercurl = true },
		    ['DiagnosticUnderlineWarn'] = { fg = palette.color2, undercurl = true },
		    ['DiagnosticVirtualTextError'] = { link = 'DiagnosticError' },
		    ['DiagnosticVirtualTextHint'] = { link = 'DiagnosticHint' },
		    ['DiagnosticVirtualTextInfo'] = { link = 'DiagnosticInfo' },
		    ['DiagnosticVirtualTextWarn'] = { link = 'DiagnosticWarn' },

        -------------------------------
        --          Plugins          --
        -------------------------------

        --      hrsh7th/nvim-cmp    --

            --for experimental feature ghost_text
            --requires to have ghost_text = GhostText in experimental
            --features

        ['GhostText'] = { fg = palette.color2, italic = option.italic },

        ['CmpItemAbbr'] = { fg = palette.subtle },
		    ['CmpItemAbbrDeprecated'] = { fg = palette.subtle, strikethrough = true },
		    ['CmpItemAbbrMatch'] = { fg = palette.text, bold = true },
		    ['CmpItemAbbrMatchFuzzy'] = { fg = palette.text, bold = true },

		    ['CmpItemKind'] = { fg = palette.subtle },
		    ['CmpItemKindClass'] = { fg = palette.color4 },
		    ['CmpItemKindFunction'] = {  fg = palette.color4 },
		    ['CmpItemKindInterface'] = { fg = palette.color3 },
		    ['CmpItemKindMethod'] = { fg = palette.color6 },
            ['CmpItemKindProperty'] = { fg = palette.color1 },

		    ['CmpItemKindSnippet'] = { fg = palette.subtle, italic = true },
		    ['CmpItemKindVariable'] = { link = '@variable' },

        --      nvim-treesitter/nvim-treesitter     --
        --
        -- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md?plain=1
        ['TreesitterContext'] = { bg = palette.surface, bold = true },
        ['TreesitterContextBottom'] = { bg = option.surface, italic = option.italic },
        ['TreesitterContextLineNumber'] = { bg = palette.surface, bold = true, underline = true },
        ['TreesitterContextLineNumberBottom'] = { bg = palette.surface, italic = option.italic },

        -- TS refactor highlighting 
        ['TsDefinition'] = { bg = palette.visual, fg = palette.base },
        ['TsDefinitionUsage'] = { bg = palette.visual, fg = palette.base },
        --['TsCurrentScope'] = { bg = palette.subtle },

        --@text.literal      Comment
        --@text.reference    Identifier
        --@text.title        Title
        --@text.uri          Underlined
        --@text.underline    Underlined
        --@text.todo         Todo

        --@comment           Comment
        --@punctuation       Delimiter
            --delimiters (e.g. `;` / `.` / `,`)
        ['@punctuation.delimiter'] = { link = "Delimiter" },
            --brackets (e.g. `()` / `{}` / `[]`)
        ['@punctuation.bracket'] = { fg = palette.subtle },
            --special symbols (e.g. `{}` in string interpolation)
        ['@punctuation.special'] = { fg = palette.subtle },

        --@constant          Constant
        --@constant.builtin  Special
        --@constant.macro    Define
        --@define            Define
        ['@macro'] = { link = 'Macro' },
            --String
        ['@string'] = { link = 'String'},
            --SpecialChar
        --['@string.escape'] = { fg = palette.color6 },
        -- SpecialChar
        ['@string.special'] = { link = 'Special' },
        --@character         Character
        --@character.special SpecialChar
        -- ['@number'] = { link = 'Number' },
        --@boolean           Boolean
        -- ['@float'] = { link = 'Number'},

            --Function
        ['@function'] = { link = 'Function' },
        ['@function.builtin'] = { link = 'Macro' },
        --@function.macro    Macro
            --Identifier
        ['@parameter'] = { fg = palette.color9, italic = option.italic },
            --Function
        ['@method'] = { fg = palette.color1 },
        --@field             Identifier
            --Identifier
        ['@property'] = { fg = palette.color1 },
            --Special
        ['@constructor'] = { link = '@punctuation.bracket' },

            --Conditional
        ['@conditional'] = { fg = palette.color5 },
        --@repeat            Repeat
            --Label
        ['@label'] = { fg = palette.color3 },
            --Operator
        ['@operator'] = { link = 'Operator' },
            --various keywords
        ['@keyword'] = { fg = palette.color5 },
            --keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
        ['@keyword.coroutine'] = { link = 'special' },
            --keywords that define a function (e.g. `func` in Go, `def` in Python)
        --@keyword.function  
            --operators that are English words (e.g. `and` / `or`)
        ['@keyword.operator'] = { fg = palette.color4 },
            --keywords like `return` and `yield`
        --@keyword.return 
            --Exception
        ['@exception'] = { fg = palette.color0 },

            --Identifier
        ['@variable'] = { fg = palette.color2 },
            --built-in variable names (e.g. `this`)
        ['@variable.builtin'] = { fg = palette.color3 },
        ['@default.builtin'] = { fg = palette.color11 },
            --Type
        ['@type'] = { link = 'Type' },
        --@type.definition   Typedef
        --@storageclass      StorageClass
        --@structure         Structure
            --Identifier
        ['@namespace'] = { fg = palette.color6 },
        -- symbols or atoms
        ['@symbol'] = { fg = palette.color0 },
        ['@interface'] = { fg = palette.color3 },
        -- ['@spell'] = { link = 'Comment'},

        --@include           Include
        --@preproc           PreProc
        --@debug             Debug
            --XML tag names
        ['@tag'] = { fg = palette.color1 },
        --@tag.attribute ; XML tag attributes
        --XML tag delimiters
        ['@tag.delimiter'] = { fg = palette.color5 },
        -- HTML tags
        ['@tag.attribute.html'] = { fg = palette.color3 },

        --      LSP Base     --

        ['@lsp.type.comment'] = { link = "Comment"},
		    ['@lsp.type.enum'] = { link = '@type' },
		    ['@lsp.type.keyword'] = { link = '@keyword' },
		    ['@lsp.type.interface'] = { link = '@interface' },
		    ['@lsp.type.namespace'] = { link = '@namespace' },
		    ['@lsp.type.parameter'] = { link = '@parameter' },
		    ['@lsp.type.property'] = { fg = palette.color1 },
		    ['@lsp.type.method'] = {}, -- use treesitter styles for regular variable
		    ['@lsp.type.variable'] = { link = '@variable' },
		    ['@lsp.typemod.function.defaultLibrary'] = { link = 'Special' },
		    ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },


		    -- LSP Injected Groups
		    ['@lsp.typemod.operator.injected'] = { link = '@operator' },
		    ['@lsp.typemod.string.injected'] = { link = '@string' },
		    ['@lsp.typemod.variable.injected'] = { link = '@variable' },

            --      nvim-telescope/telescope.nvim       --

            ['TelescopeBorder'] = { fg = palette.muted, bg = palette.base },
		    ['TelescopeMatching'] = { fg = palette.color2 },
		    ['TelescopeNormal'] = { fg = palette.subtle, bg = float_background },
		    ['TelescopePromptNormal'] = { fg = palette.text, bg = float_background },
		    ['TelescopePromptPrefix'] = { fg = palette.subtle },
		    ['TelescopeSelection'] = { fg = palette.color1, bg = palette.surface },
		    ['TelescopeSelectionCaret'] = { fg = palette.color3, bg = palette.surface },
		    ['TelescopeTitle'] = { fg = palette.subtle },

        -------------------------------
        --    Language Overwrites    --
        -------------------------------

        --          lua              --

        -- leave to treesitter
        ['@lsp.type.variable.lua'] = { link = '' },
        ['@lsp.type.function.lua'] = { link = '' },
        ['@lsp.typemod.function.defaultLibrary.lua'] = { link = '' },
        ['@lsp.typemod.variable.defaultLibrary.lua'] = { link = '' },

        --['@function.builtin.lua'] = { fg = palette.color6 },
        ['@keyword.coroutine.lua'] = { link = 'Special' },
        --['@variable.builtin.lua'] = { link = ''}

        --          rust            --

        ['@lsp.type.macro.rust'] = { link = '@macro' },
        ['@keyword.modifier.rust'] = { link = 'special' },
        ['@lsp.typemod.function.defaultLibrary.rust'] = { link = '@function' },
        --['@lsp.mod.defaultLibrary.rust'] = { link = '@variable.builtin'},
        --['@variable.builtin.rust'] = { fg = palette.color11 },
        --['@lsp.typemod.macro.library.rust'] = { link = '@macro'},
        --['@lsp.typemod.namespace.library.rust'] = { link = '@namespace' },

        --          golang          --

        ['@variable.member.go'] = { link = '@property' },
        ['@module.go'] = { link = '@namespace' },
        ['@spell.go'] = {},


        --          c               --

        ['@keyword.import.c'] = { link = '@namespace' },
        ['@lsp.type.macro.c'] = { link = '@macro' },
        ['@lsp.typemod.function.defaultLibrary.c'] = { link = '@function' },

        --      javascript          --

        ['@tag.attribute.javascript'] = { link = '@tag.attribute.html'},
        ['@variable.member.javascript'] = { link = '@property'},
        ['@keyword.exception.javascript'] = { fg = palette.color0 },
        ['@lsp.type.method.javascript'] = { link = '@function' },
        ['@lsp.type.class.javascript'] = { link = '@macro' },
        ['@constructor.javascript'] = { link = '@macro' },
        ['@lsp.typemod.variable.defaultLibrary.javascript'] = { link = '@default.builtin' },
        ['@lsp.typemod.function.defaultLibrary.javascript'] = { link = '@function' },

        ['@lsp.type.class.typescript'] = { link = '@macro' },
        ['@constructor.typescript'] = { link = '@macro' },
        ['@lsp.typemod.variable.defaultLibrary.typescript'] = { link = '@default.builtin' },
        ['@lsp.typemod.function.defaultLibrary.typescript'] = { link = '@function' },
        ['@keyword.coroutine.typescript'] = { link = 'Special' },

        --['@string.css'] = { fg = palette.color9 },
        ['@operator.css'] = { link = 'Special' },
        ['@keyword.directive.css'] = { link = '@macro' },
        ['@tag.css'] = { fg = palette.color0 },
        ['@keyword.modifier.css'] = { fg = palette.color3, italic = true },

        --      python      --

        ['@variable.parameter.python'] = { link = '@parameter' },
        ['@variable.member.python'] = { link = '@property' },
        ['@constructor.python'] = { link = '@macro' },
        ['@module.python'] = { link = '@namespace' },
        ['@attribute.builtin.python'] = { fg = palette.color11 },
        ['@type.python'] = { link = '@macro' }
        --['@operator.python'] = { fg = palette.color11 },
    }

    -- set terminal colors
    vim.g.terminal_color_0 = palette.base
    vim.g.terminal_color_1 = palette.color0
    vim.g.terminal_color_2 = palette.color8
    vim.g.terminal_color_3 = palette.color2
    vim.g.terminal_color_4 = palette.color3
    vim.g.terminal_color_5 = palette.color1
    vim.g.terminal_color_6 = palette.color9
    vim.g.terminal_color_7 = palette.text
    vim.g.terminal_color_8 = palette.surface
    vim.g.terminal_color_9 = palette.color4
    vim.g.terminal_color_10 = palette.color10
    vim.g.terminal_color_11 = palette.color6
    vim.g.terminal_color_12 = palette.color7
    vim.g.terminal_color_13 = palette.color5
    vim.g.terminal_color_14 = palette.color11
    vim.g.terminal_color_15 = palette.subtle

    -- Set a highlight with a default priority
    local status, hooks = pcall(require, 'ibl.hooks')
    if status then
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, 'high1', { fg = palette.surface })
        end)

        require('ibl').setup {
            indent = { highlight = { 'high1' } , char = '|'},
            scope = { enabled = false}
            --scope = { highlight = { 'high2'} }
        }
    end

    for key, value in pairs(theme) do
        local fg = value.fg or 'none'
        local bg = value.bg or 'none'
        local sp = value.sp or 'none'

        local values = vim.tbl_extend('force', value, { fg = fg, bg = bg, sp = sp })
        vim.api.nvim_set_hl(0, key, values)
    end
    vim.cmd('match Todo /TODO/')
end

return m
