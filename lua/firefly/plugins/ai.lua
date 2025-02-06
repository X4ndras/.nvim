local current_deepseek_model = "deepseek-chat"

-- Create commands for model switching
vim.api.nvim_create_user_command("DeepseekChat", function()
  current_deepseek_model = "deepseek-chat"
  print("Switched to Deepseek Chat model")
end, {})

vim.api.nvim_create_user_command("DeepseekReasoner", function()
  current_deepseek_model = "deepseek-reasoner"
  print("Switched to Deepseek Reasoner model")
end, {})


require('avante').setup({
  provider = "openai",
  --auto_suggestions_provider = "ollama",
  openai = {
    endpoint = "https://api.deepseek.com/v1",
    model = "deepseek-reasoner",
    timeout = 30000,
    temperature = 0,
    max_tokens = 4096,
    api_key_name = "DEEPSEEK_API_KEY",  -- Environment variable name
  },
  vendors = {
    ollama = {
      __inherited_from = "openai",
      api_key_name = "",
      endpoint = "http://127.0.0.1:11434/v1",
      model = "deepseek-coder-v2:latest",
    },
  },
  chat_history = {
    enabled = true,
    max_history = 50,
    storage_path = vim.fn.stdpath('data') .. '/avante_chat_history.json',
  },
  behaviour = {
    auto_focus_sidebar = true,
    auto_suggestions = true,
    auto_suggestions_respect_ignore = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    jump_result_buffer_on_finish = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
  },
  history = {
    max_tokens = 4096,
    storage_path = vim.fn.stdpath("state") .. "/avante",
  },
  windows = {
    sidebar_header = {
      --enabled = false,
      align = "center",
      rounded = true
    },
    input = {
      prefix = "> ",
      height = 16,
    },
  }
})


--[[
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
             default = current_deepseek_model
           },
        },
      })
    end,
  },
  display = {
    chat = {
      show_settings = true
    },
    diff = {
      enabled = true,
      close_chat_at = 240,
      layout = "vertical",
      opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
      provider = "default",
    },
  },
  strategies = {
    chat = { adapter = "deepseek", },
    inline = { adapter = "deepseek" },
    --agent = { adapter = "deepseek" },
  },
})
]]--
