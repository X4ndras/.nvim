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

    {
      "olimorris/codecompanion.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      config = true
    },

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
    'nvim-treesitter/nvim-treesitter-refactor',

    'onsails/lspkind.nvim',

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
