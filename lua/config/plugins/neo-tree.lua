local map = vim.keymap.set

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
        },
    },

    filesystem = {
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
