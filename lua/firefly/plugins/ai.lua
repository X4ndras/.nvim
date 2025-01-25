local fmt = string.format
local promts = {}

require("codecompanion").setup({
  adapters = {
    deepseek = function()
      return require("codecompanion.adapters").extend("deepseek", {
        env = {
          api_key = "DEEPSEEK_API_KEY",
        },
        schema = {
           model = {
             --default = "deepseek-reasoner",
             default = "deepseek-chat",
           },
        },
      })
    end,
  },
  display = {
    chat = {
      show_settings = true
    }
  },
  strategies = {
    chat = { adapter = "deepseek", },
    inline = { adapter = "deepseek" },
    agent = { adapter = "deepseek" },
  },
})

    -- Custom Parameters (with defaults)
    --[[
    {
        "David-Kunz/gen.nvim",
        opts = {
            model = "mistral", -- The default model to use.
            quit_map = "q", -- set keymap to close the response window
            retry_map = "<c-r>", -- set keymap to re-send the current prompt
            accept_map = "<c-a>", -- set keymap to replace the previous selection with the last result
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

    {
      "nomnivore/ollama.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim"
      },
      opts = {
        model = "phi3:3.8b",
      }
    },
    ]]--

--[[
return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    -- set this if you want to always pull the latest change
    version = false,
    opts = {
        provider = "openai",
        --auto_suggestions_provider = "openai",
        openai = {
            endpoint = "https://api.deepseek.com/v1",
            model = "deepseek-chat",
            -- Timeout in milliseconds
            timeout = 30000,
            temperature = 0.3,
            max_tokens = 4096,
            -- optional
            api_key_name = "DEEPSEEK_API_KEY",
        },
        behaviour = {
            auto_suggestions = false, -- Experimental stage
            auto_set_highlight_group = true,
            auto_set_keymaps = true,
            auto_apply_diff_after_generation = false,
            support_paste_from_clipboard = false,
            minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        },
        keymaps = {
            submit = "<M-CR>",  -- Alt+Enter for submitting
        },
        hints = {
          enabled = false
        },
    },
    hints = {
      enabled = false
    },
    build = "make",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },

}

]]--


