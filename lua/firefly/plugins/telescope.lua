local actions = require "telescope.actions"
local telescopeConfig = require("telescope.config")

---@diagnostic disable-next-line: deprecated
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

table.insert(vimgrep_arguments, "--hidden")

table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

require('telescope').setup{
    defaults = {
        border = true,
        sorting_strategy = "ascending",
        color_devicons = true,
        prompt_prefix = "   ",
        selection_caret = "󰄾 ",
        file_ignore_patterns = {
            'node_modules/*',
            'lsps/*',
            '.venv/*',
            'target/*',
        },
        mappings = {
            i = {
                 ['<M-j>'] = actions.move_selection_next,
                 ['<M-k>'] = actions.move_selection_previous,
                 ['<M-i>'] = actions.select_default,
                 ['<M-;>'] = actions.close,
                 ['<Esc>'] = actions.close
            }
        },
    },
    pickers = {
        find_files = {
            theme = 'dropdown',
        },
        live_grep = {
            theme = 'dropdown',
        },
        registers = {
            theme = 'dropdown',
        },
    },
    extensions = {
        file_browser = {
            hijack_netrw = true,
        },
    },
}

pcall(require('telescope').load_extension, 'file_browser')
