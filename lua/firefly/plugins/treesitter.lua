require'nvim-treesitter.configs'.setup {
    refactor = {
        highlight_definitions = {
            enable = true,
            clear_on_cursor_move = false,
        },
        navigation = {
            enable = false,
            keymaps = {
                --smart_rename = "grr",
                --goto_definition = "gnd",
                --list_definitions = "gnD",
                --list_definitions_toc = "gO",
                --goto_next_usage = "<a-*>",
                --goto_previous_usage = "<a-#>",
            }
        }
    },

    ensure_installed = {
        "c",
        "lua",
        "markdown",
        "rust",
        "go",
        "javascript",
        "html",
        "css"
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,


    highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}
