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
      position = "bottom", -- | top | left | right | horizontal | vertical
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
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})

local multi_file_selector = function(params)
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local themes       = require("telescope.themes")

  local filepaths    = params.filepaths or {}

  if vim.tbl_isempty(filepaths) and type(params.get_filepaths) == "function" then
    filepaths = params.get_filepaths()
  end

  filepaths = vim.tbl_filter(function(fp)
    local name = vim.fn.fnamemodify(fp, ":t")
    -- Ignore files (or directories) that start with '.'
    if name:sub(1, 1) == "." then
      return false
    end

    local stat = vim.loop.fs_stat(fp)
    if stat and stat.type == "directory" then
      return false
    end

    return true
  end, filepaths)

  local dropdown_opts = themes.get_dropdown({
    winblend = 10,
    width = 0.6,
    previewer = false,
    prompt_title = "(Avante) Select files (Multi-select with <Tab>) ",
  })

  pickers.new(dropdown_opts, {
    finder = finders.new_table(filepaths),
    sorter = conf.file_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<esc>", actions.close)

      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()

        if #selections == 0 then
          selections = { action_state.get_selected_entry() }
        end

        local selected_paths = {}
        for _, selection in ipairs(selections) do
          table.insert(selected_paths, selection.value)
        end

        actions.close(prompt_bufnr)
        if params and params.handler then
          params.handler(selected_paths)
        end
      end)

      return true
    end,
  }):find()
end


require('avante').setup({
  --provider = "openai",
  provider = "deepseek-reasoner",
  --auto_suggestions_provider = "",
  vendors = {
    ["deepseek-coder"] = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-coder",
      temperature = 0,
    },
    ["deepseek-reasoner"] = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      temperature = 0,
      model = "deepseek-reasoner",
      disable_tools = true
    },
    ["deepseek-chat"] = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-chat",
    },
    ["claude-3.7"] = {
      __inherited_from = "copilot",
      model = "claude-3.7-sonnet",
    },
    ["claude-3.5"] = {
      __inherited_from = "copilot",
      model = "claude-3.5-sonnet",
    }
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
    width = 32,
    sidebar_header = {
      enabled = false,
      align = "center",
      rounded = true
    },
    input = {
      prefix = "> ",
      height = 16,
    },
  },
  mappings = {
    ---@class AvanteConflictMappings
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<M-CR>",
    },
    -- NOTE: The following will be safely set by avante.nvim
    ask = "<leader>aq",
    edit = "<leader>ae",
    refresh = "<leader>ar",
    focus = "<leader>af",
    stop = "<leader>aS",
    toggle = {
      default = "<leader>ac",
      debug = "<leader>ad",
      hint = "<leader>ah",
      suggestion = "<leader>as",
      repomap = "<leader>aR",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      retry_user_request = "r",
      edit_user_request = "e",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "d",
      add_file = "#",
      close = { "<C-w>c" },
      close_from_input = nil,
    },
    files = {
      add_current = "<leader>aa", -- Add current buffer to selected files
    },
    select_model = "<leader>am", -- Select model command
    select_history = "<leader>ah", -- Select history command
  },
  repo_map = {
    ignore_patterns = { "%.git", "%.worktree", "__pycache__", "node_modules" }, -- ignore files matching these
    negate_patterns = {},                                                       -- negate ignore files matching these.
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
            default = "deepseek-reasoner",
          },
        },
      })
    end,
    copilot = function()
      return require("codecompanion.adapters").extend("copilot", {
        schema = {
          model = {
            default = "claude-3.7-sonnet",
          },
        },
      })
    end,
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
    chat = { adapter = "copilot", },
    inline = { adapter = "copilot" },
  },
})

vim.keymap.set("n", "<Leader>cc", function() vim.cmd("CodeCompanionChat toggle") end)
vim.keymap.set("n", "<Leader>cn", function() vim.cmd("CodeCompanionChat") end, { desc = "Open new CodeCompanion chat" })
]]--
