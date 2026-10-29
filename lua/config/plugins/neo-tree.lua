local map = vim.keymap.set

-- Open the file under the cursor but keep the cursor in the tree.
-- Folders expand/collapse as with <cr>.
local function open_keep_focus(state)
    local node = state.tree:get_node()
    if not node or node.type ~= "file" then
        state.commands.open(state)
        return
    end
    local win = state.winid
    local cursor = vim.api.nvim_win_get_cursor(win)
    -- Opening a file makes the tree "follow" it: it reveals the file, which
    -- can expand folders or land on another row with the same path (e.g. in
    -- an overlapping project). Skip that and keep the cursor on this row.
    require("workspace.explorer").skip_follow()
    state.commands.open(state)
    if not vim.api.nvim_win_is_valid(win) then
        return
    end
    vim.api.nvim_set_current_win(win)
    -- Neo-tree's own follow runs debounced (100 ms); restore after it.
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_set_cursor, win, cursor)
        end
    end, 150)
end

-- Neo-tree uses "o" as the prefix for its sort keys (oc, on, ...), which
-- would make a plain "o" wait for a second key. Move them to "O".
local function o_mappings()
    local mappings = {}
    mappings["o"] = open_keep_focus
    mappings["O"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "O" } }
    for key, command in pairs({
        c = "order_by_created",
        d = "order_by_diagnostics",
        g = "order_by_git_status",
        m = "order_by_modified",
        n = "order_by_name",
        s = "order_by_size",
        t = "order_by_type",
    }) do
        mappings["o" .. key] = "none"
        mappings["O" .. key] = { command, nowait = false }
    end
    return mappings
end

require("neo-tree").setup({
    enable_git_status = true,
    enable_diagnostics = true,

    sources = {
        "filesystem",
        "buffers",
        "git_status",
        -- Virtual multi-root workspace (lua/workspace)
        "workspace.explorer",
    },

    window = {
        mappings = {
            -- <space> is the leader key; Neo-tree would swallow it (and with
            -- it every <leader> mapping, e.g. <leader>m) inside the tree.
            -- Folders still toggle with <cr>.
            ["<space>"] = "none",
            ["o"] = open_keep_focus,
        },
    },

    buffers = { window = { mappings = o_mappings() } },
    git_status = { window = { mappings = o_mappings() } },

    filesystem = {
        window = { mappings = o_mappings() },
        hijack_netrw_behavior = "disabled",
        follow_current_file = {
            enabled = true,
        },
        components = {
            -- Root folder shows the repo's branch and tag (or commit).
            name = function(config, node, state)
                local name = require("neo-tree.sources.common.components").name(config, node, state)
                if node:get_depth() ~= 1 or node.type ~= "directory" then
                    return name
                end
                return require("workspace.head").decorate(name, node.path)
            end,
        },
    },
})

-- A restored session (:restart, workspace switch) brings back tree windows as
-- empty buffers named "neo-tree <source> [n]". Neo-tree then can't create
-- its own buffer under that name (E95), so remove them after every session load.
vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = vim.api.nvim_create_augroup("neo_tree_session_cleanup", { clear = true }),
    callback = function()
        require("neo-tree.ui.renderer").clean_invalid_neotree_buffers(true)
    end,
})

require("workspace").setup({})
require("workspace.head").setup()

-- Workspace tree when a workspace is open, plain file tree otherwise.
-- Everything else workspace-related is in the leadm menu (<leader>m).
map("n", "<leader>e", function()
    if require("workspace").current() then
        require("workspace").toggle_tree()
    else
        vim.cmd("Neotree toggle reveal")
    end
end, {
    desc = "File tree",
})
