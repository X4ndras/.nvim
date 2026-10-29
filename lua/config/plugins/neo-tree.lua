local map = vim.keymap.set

require("neo-tree").setup({
    enable_git_status = true,
    enable_diagnostics = true,

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
    },
})


map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", {
    desc = "File tree",
})

