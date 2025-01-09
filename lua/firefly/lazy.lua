local plugins = {
    -------------------------------
    ------ Essential Plugins ------
    -------------------------------

    -- nvim lsp (Language Server)
    'neovim/nvim-lspconfig',

    -- cmp (Auto completion)
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    {
      "dundalek/lazy-lsp.nvim",
      dependencies = { "neovim/nvim-lspconfig" },
    },

    -- Custom Parameters (with defaults)
    --[[
    {
        "David-Kunz/gen.nvim",
        opts = {
            model = "mistral", -- The default model to use.
            quit_map = "q", -- set keymap to close the response window
            retry_map = "<c-r>", -- set keymap to re-send the current prompt
            accept_map = "<c-a>", -- set keymap to replace the previous selection with the last result
            host = "localhost", -- The host running the Ollama service.
            port = "11434", -- The port on which the Ollama service is listening.
            display_mode = "split", -- The display mode. Can be "float" or "split" or "horizontal-split".
            show_prompt = true, -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
            show_model = true, -- Displays which model you are using at the beginning of your chat session.
            no_auto_close = true, -- Never closes the window automatically.
            file = false, -- Write the payload to a temporary file to keep the command short.
            hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
            init = function(options)
                pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
            end,
            -- Function to initialize Ollama
            command = function(options)
                local body = {
                    model = options.model,
                    stream = true,
                    temperature = 0
                }
                return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
            end,
            result_filetype = "markdown", -- Configure filetype of the result buffer
            debug = false -- Prints errors and the command which is run.
        }
    },
    ]]--


    {
       'nvimdev/lspsaga.nvim',
       dependencies = {
        'nvim-treesitter/nvim-treesitter',
       }
    },

    -- Snippets 
    { 'L3MON4D3/LuaSnip', version = "v2.3.0" },
    -- Snippets 
    'rafamadriz/friendly-snippets',
    'saadparwaiz1/cmp_luasnip',

    -- autoclosing (), {}, [], etc...
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {}},

    -- Autoclosing tags (<html></html>)
    'windwp/nvim-ts-autotag',

    --{'rust-lang/rust.vim'},
    -- This plugin is already lazy
    --{ 'mrcjkb/rustaceanvim', version = '^5', lazy = false, },

    -------------------------------------
    ------ Quality of life plugins ------
    -------------------------------------

    -- Filesearch, Live Grep
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep' },
    },

    -- code hilighting 
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'onsails/lspkind.nvim'},

    -- color colorcode 
    'norcalli/nvim-colorizer.lua',

    -- indent lines
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

    -- Undo tree
    'mbbill/undotree',

    -- Smooth Scrolling
    {
        "declancm/cinnamon.nvim",
        version = "*",
        opts = {
        },
    },

    -- Undo tree
    'mbbill/undotree',

    -- Smooth Scrolling
    {
        "declancm/cinnamon.nvim",
        version = "*",
        opts = {
        },
    },

    -- game
    -- 'ThePrimeagen/vim-be-good',

    -------------------------
    ------ Own Plugins ------
    -------------------------

    --'X4ndras/pristine-mint',
    -- 'X4ndras/firefly-theme',

    { dir = '~/.config/nvim/plugs/firefly-theme' },
    { dir = '~/.config/nvim/plugs/bufopt' },
}

require('lazy').setup(plugins)
