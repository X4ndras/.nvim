local telescope = require("telescope")
local builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local map = vim.keymap.set

telescope.setup({})

local function git_diff()
    local root = vim.fn.getcwd()

    local git_dirs = vim.fs.find(".git", {
        path = root,
        limit = math.huge,
    })

    local repos = {}
    local seen = {}

    for _, git_path in ipairs(git_dirs) do
        local repo = vim.fs.dirname(git_path)

        if not seen[repo] then
            seen[repo] = true
            table.insert(repos, repo)
        end
    end

    table.sort(repos)

    if #repos == 0 then
        vim.notify("No Git repositories found", vim.log.levels.INFO)
        return
    end

    pickers.new({}, {
        prompt_title = "Git repositories",

        finder = finders.new_table({
            results = repos,

            entry_maker = function(repo)
                local relative = vim.fs.relpath(root, repo) or repo

                if relative == "" then
                    relative = "."
                end

                return {
                    value = repo,
                    display = relative,
                    ordinal = relative,
                }
            end,
        }),

        sorter = config.generic_sorter({}),

        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()

                actions.close(prompt_bufnr)

                if selection then
                    vim.cmd(
                        "DiffviewOpen -C"
                            .. vim.fn.fnameescape(selection.value)
                    )
                end
            end)

            return true
        end,
    }):find()
end

map("n", "<leader><leader>", builtin.find_files, {
    desc = "Find files",
})

map("n", "<leader>ff", builtin.live_grep, {
    desc = "Find text",
})

map("n", "<leader>fb", builtin.buffers, {
    desc = "Find buffers",
})

map("n", "<leader>fg", git_diff, {
    desc = "Git diff repository",
})
