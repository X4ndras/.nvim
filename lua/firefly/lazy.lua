local plugins = {
  -------------------------------
  ------ Essential Plugins ------
  -------------------------------

  -- Theme (loaded fully asynchronously after startup)
  {
    dir = '~/.config/nvim/plugs/firefly-theme',
    lazy = true, -- Don't auto-load
  },

  -- nvim lsp (Language Server) - defer until file is opened
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "dundalek/lazy-lsp.nvim",
    },
    config = function()
      require('firefly.plugins.lspconfig')
    end,
  },

  -- cmp (Auto completion) - defer until insert mode
  {
    'hrsh7th/nvim-cmp',
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'saadparwaiz1/cmp_luasnip',
      {
        'L3MON4D3/LuaSnip',
        version = "v2.3.0",
        dependencies = { 'rafamadriz/friendly-snippets' },
      },
    },
    config = function()
      require('firefly.plugins.cmp')
    end,
  },

  -- Harpoon - lazy load on keymap
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", desc = "Harpoon add" },
      { "<leader>hh", desc = "Harpoon menu" },
      { "<leader>1", desc = "Harpoon 1" },
      { "<leader>2", desc = "Harpoon 2" },
      { "<leader>3", desc = "Harpoon 3" },
      { "<leader>4", desc = "Harpoon 4" },
    },
    config = function()
      require('firefly.plugins.harpoon')
    end,
  },

  -- autoclosing (), {}, [], etc...
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  -- Autoclosing tags (<html></html>)
  {
    'windwp/nvim-ts-autotag',
    event = "InsertEnter",
    config = function()
      require('firefly.plugins.autotag')
    end,
  },

  -------------------------------------
  ------ Quality of life plugins ------
  -------------------------------------

  -- Filesearch, Live Grep - lazy load on keymap
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep' },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", desc = "Find files" },
      { "<leader>fg", desc = "Live grep" },
      { "<leader>fb", desc = "Buffers" },
      { "<leader>fh", desc = "Help tags" },
    },
    config = function()
      require('firefly.plugins.telescope')
    end,
  },

  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },

  -- File tree with git status
  {
    'nvim-tree/nvim-tree.lua',
    lazy = true,
    module = 'nvim-tree',
    dependencies = {
      {
        'nvim-tree/nvim-web-devicons',
        opts = {
          color_icons = false,
          default = true,
        },
      },
    },
    config = function()
      require('firefly.plugins.nvim_tree')
    end,
  },

  -- code hilighting - defer until file is opened
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { 'nvim-treesitter/nvim-treesitter-refactor' },
    config = function()
      require('firefly.plugins.treesitter')
    end,
  },

  -- Diffview - lazy load on command
  {
    'sindrets/diffview.nvim',
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
  },

  -- NeoGit
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua",              -- optional
      -- "nvim-mini/mini.pick",           -- optional
      --"folke/snacks.nvim",             -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
    }
  },

  -- LSP icons
  { 'onsails/lspkind.nvim', event = "InsertEnter" },

  -- color colorcode - defer to VeryLazy
  {
    'norcalli/nvim-colorizer.lua',
    event = "VeryLazy",
    config = function()
      require('colorizer').setup()
    end,
  },

  -- indent lines - defer until file is opened
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Undo tree - lazy load on command/keymap
  {
    'mbbill/undotree',
    cmd = "UndotreeToggle",
  },

  -- Smooth Scrolling - defer to VeryLazy
  {
    "declancm/cinnamon.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Markdown rendering
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { "markdown", "codecompanion" },
  },

  -- AI: Copilot - defer to InsertEnter
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "<M-,>",
            jump_next = "<M-.>",
            accept = "<CR>",
            refresh = "gr",
            open = "<C-CR>c"
          },
          layout = {
            position = "bottom",
            ratio = 0.2
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = false,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          markdown = true,
          gitcommit = true,
          yaml = false,
          help = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      })
    end,
  },

  -- AI: CodeCompanion - lazy load on command/keymap
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "zbirenbaum/copilot.lua",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<Leader>cc", "<cmd>CodeCompanionChat toggle<CR>", desc = "CodeCompanion Chat" },
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            copilot = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  model = {
                    default = "claude-3.7-sonnet",
                  },
                },
              })
            end,
            acp = {
              claude_code = function()
                return require("codecompanion.adapters").extend("claude_code")
              end,
            },
          },
        },
        display = {
          action_palette = {
            provider = "telescope"
          },
          chat = {
            show_settings = true,
            show_header_seperator = true,
            show_references = true,
          },
          diff = {
            enabled = true,
            layout = "horizontal",
            provider = "default",
          },
        },
        strategies = {
          chat = { adapter = "claude_code", },
          inline = { adapter = "claude_code" },
        },
      })
    end,
  },

  -- vim-tidal - only for tidal files
  {
    'tidalcycles/vim-tidal',
    ft = "tidal",
  },

  -------------------------
  ------ Own Plugins ------
  -------------------------

  { dir = '~/.config/nvim/plugs/bufopt', event = "VeryLazy" },
}

require('lazy').setup(plugins, {
  -- Performance optimizations
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
