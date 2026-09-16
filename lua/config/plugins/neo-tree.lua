local map = vim.keymap.set

require("neo-tree").setup({
    enable_git_status = true,
    enable_diagnostics = true,

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

