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


local multi_file_selector = function(params)
  local pickers       = require("telescope.pickers")
  local finders       = require("telescope.finders")
  local conf          = require("telescope.config").values
  local actions       = require("telescope.actions")
  local action_state  = require("telescope.actions.state")

  local filepaths = params.filepaths or {}

  if vim.tbl_isempty(filepaths) and type(params.get_filepaths) == "function" then
    filepaths = params.get_filepaths()
  end

  -- Filter out directories and hidden files (files starting with ".")
  filepaths = vim.tbl_filter(function(fp)
    -- Get the basename of the file
    local name = vim.fn.fnamemodify(fp, ":t")
    -- Ignore files (or directories) that start with '.'
    if name:sub(1, 1) == "." then
      return false
    end

    -- Use vim.loop.fs_stat to check if the path is a directory.
    local stat = vim.loop.fs_stat(fp)
    if stat and stat.type == "directory" then
      return false
    end

    return true
  end, filepaths)

  pickers.new({}, {
    prompt_title = "(Avante) Select files (Multi-select with <Tab>)",
    finder = finders.new_table(filepaths),
    sorter = conf.file_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<esc>", actions.close)

      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()

        -- If nothing was multi-selected, fall back to single selection.
        if #selections == 0 then
          selections = { action_state.get_selected_entry() }
        end

        local selected_paths = {}

        for _, selection in ipairs(selections) do
          -- Each selection is assumed to have a `value` field with the relative filepath.
          table.insert(selected_paths, selection.value)
        end

        actions.close(prompt_bufnr)

        -- Call the handler (as defined in Avante’s selector)
        -- This handler is expected to iterate over the filepaths and add them accordingly.
        if params and params.handler then
          params.handler(selected_paths)
        end
      end)

      return true
    end,
  }):find()
end

require('avante').setup({
  provider = "openai",
  --auto_suggestions_provider = "",
  openai = {
    endpoint = "https://api.deepseek.com/v1",
    model = "deepseek-coder",
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
    auto_suggestions = false,
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
  },
  repo_map = {
    ignore_patterns = { "%.git", "%.worktree", "__pycache__", "node_modules" }, -- ignore files matching these
    negate_patterns = {}, -- negate ignore files matching these.
  },
  --- @class AvanteFileSelectorConfig
  file_selector = {
    --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
    provider = multi_file_selector,
    -- Options override for custom providers
    provider_opts = {},
  },

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
