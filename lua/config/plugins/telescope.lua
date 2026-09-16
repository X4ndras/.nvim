local telescope = require("telescope")
local builtin = require("telescope.builtin")
local map = vim.keymap.set

telescope.setup({})

map("n", "<leader><leader>", builtin.find_files, {
    desc = "Find files",
})

map("n", "<leader>ff", builtin.live_grep, {
    desc = "Find text",
})

map("n", "<leader>fb", builtin.buffers, {
    desc = "Find buffers",
})
