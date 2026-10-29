local telescope = require("telescope")
local builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local map = vim.keymap.set

telescope.setup({
    defaults = {
        mappings = {
            -- Move through results while typing, without leaving the prompt.
            i = {
                ["<M-j>"] = actions.move_selection_next,
                ["<M-k>"] = actions.move_selection_previous,
            },
        },
    },
})

local function git_diff()
    local root = vim.fn.getcwd()
    local repos = {}

    local workspace = require("workspace").current()

    if workspace then
        -- Only the repositories of the open workspace.
        repos = require("workspace.repos").all(workspace)
        root = vim.uv.os_homedir()
    else
        local git_dirs = vim.fs.find(".git", {
            path = root,
            limit = math.huge,
        })

        local seen = {}

        for _, git_path in ipairs(git_dirs) do
            local repo = vim.fs.dirname(git_path)

            if not seen[repo] then
                seen[repo] = true
                table.insert(repos, repo)
            end
        end

        table.sort(repos)
    end

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

-- With a workspace open, search only its projects; otherwise the cwd.
local function workspace_dirs()
    local workspace = require("workspace").current()
    if not workspace then
        return nil
    end
    local dirs = vim.tbl_filter(function(dir)
        return vim.uv.fs_stat(dir) ~= nil
    end, require("workspace.store").projects(workspace))
    return #dirs > 0 and dirs or nil
end

local function in_workspace(picker, title)
    return function()
        local dirs = workspace_dirs()
        if not dirs then
            picker()
            return
        end
        picker({
            search_dirs = dirs,
            prompt_title = title .. " (" .. require("workspace").current().name .. ")",
            path_display = function(_, path)
                return vim.fn.fnamemodify(path, ":~")
            end,
        })
    end
end

map("n", "<leader><leader>", in_workspace(builtin.find_files, "Find files"), {
    desc = "Find files",
})

map("n", "<leader>s", in_workspace(builtin.live_grep, "Find text"), {
    desc = "Find text",
})

map("n", "<leader>fb", builtin.buffers, {
    desc = "Find buffers",
})

map("n", "<leader>fg", git_diff, {
    desc = "Git diff repository",
})
