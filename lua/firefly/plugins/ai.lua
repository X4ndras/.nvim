local fmt = string.format
local promts = {}

require("codecompanion").setup({
  adapters = {
    deepseek = function()
      return require("codecompanion.adapters").extend("deepseek", {
        env = {
          api_key = "DEEPSEEK_API_KEY",
        },
        -- schema = {
        --   model = {
        --     default = "deepseek-reasoner",
        --   },
        -- },
      })
    end,
  },
  strategies = {
    chat = { adapter = "deepseek", },
    inline = { adapter = "deepseek" },
    agent = { adapter = "deepseek" },
  },
  prompt_library = {
    ["Generate a Clara Conventional Commit Message"] = {
      strategy = "chat",
      description = "Generate a commit message",
      opts = {
        index = 10,
        is_default = true,
        is_slash_cmd = true,
        short_name = "clara-git",
        auto_submit = true,
      },
      prompts = {
        {
          role = "user",
          content = promts.clara_git_convention,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Generate a Commit Message"] = {
      strategy = "chat",
      description = "Generate a commit message",
      opts = {
        index = 10,
        is_default = true,
        is_slash_cmd = true,
        short_name = "commit",
        auto_submit = true,
      },
      prompts = {
        {
          role = "user",
          content = function()
            return fmt(
              [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:

```diff
%s
```
]],
              vim.fn.system("git diff --no-ext-diff --staged")
            )
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    }
  }
})

promts.clara_git_convention = fmt([[
You are an expert at following the following Commit specification. 
You are Given the conventions you must follow and after that a git diff, with the changes made 
please generate a commit message for me:

# Conventional Commits

The Conventional Commits specification is a lightweight convention on top of
commit messages. It provides an easy set of rules for creating an explicit
commit history; which makes it easier to write automated tools on top of. This
convention dovetails with [SemVer](http://semver.org/), by describing the
features, fixes, and breaking changes made in commit messages.

The commit message should be structured as follows:

```
<type>(optional scope): <description>

[optional body]

[optional footer(s)]
```

Source: [conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/#summary)

The list of allowed types we're using based on
[@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%%40commitlint/config-conventional):

| type     | release | breaking | description                                                                                            | Changelog Title  |
| -------- | ------- | -------- | ------------------------------------------------------------------------------------------------------ | ---------------- |
| !        | major   | true     | Footer with `BREAKING CHANGE:` and/or `!` afer the type or scope                                       | ⚠️ BRAKING CHANGE |
| build    | patch   | false    | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)    | 🦊 Build          |
| docs     | patch   | false    | Documentation only changes                                                                             | 📔 Docs           |
| feat     | minor   | false    | A new feature                                                                                          | 🚀 feat           |
| fix      | patch   | false    | A bug fix                                                                                              | 🛠️ fix            |
| perf     | patch   | false    | A code change that improves performance                                                                | ⏩ perf           |
| revert   | patch   | false    | Reverts a previous commit                                                                              | 🙅 revert         |
| chore    | false   | false    | Other changes that don't modify src or test files                                                      | Other            |
| style    | false   | false    | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc) | 💈 style          |
| test     | false   | false    | Adding missing tests or correcting existing tests                                                      | 🧪 test           |
| ci       | false   | false    | Changes to our CI configuration files and scripts                                                      | 🦊 CI             |
| refactor | false   | false    | A code change that neither fixes a bug nor adds a feature changes                                      | ✂️ refactor       |


### Anatomy of a Commit Message

```plaintext
The subject line summarize changes (max 50 chars)

The commit body is where more context can be provided.
More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

 - Bullet points are okay, too

 - Typically a hyphen or asterisk is used for the bullet, preceded
   by a single space, with blank lines in between, but conventions
   vary here

If you use an issue tracker, put references to them at the bottom,
like this:

Resolves: #123
Related: #456, #789
ServiceNow: SRQ123456
JIRA: VIL-83

BREAKING CHANGE: This section should indicate the reason why the commit is 
introducing a breaking change.
```

### Examples for One-Line Commit Messages

```bash
a3f944c fix(backend): failing tests verifying package name
15bb908 refactor(availabilitycheck): apply PSR-2 coding guidelines
eaf678a docs(authentication): add diagrams for showing SAML sequence
ecf3589 ci: add gitlab-ci pipeline to build and release Docker images
b97edb2 feat(ui): add a view to search for k8s labels
```

```diff
%s
```
]], vim.fn.system("git diff --no-ext-diff --staged"))

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

