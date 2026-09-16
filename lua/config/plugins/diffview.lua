require("diffview").setup({
    use_icons = true,
    watch_index = true,
})

local map = vim.keymap.set

local diffview = require("diffview.lib")


local function toggle_diffview(command)
    if next(diffview.views) == nil then
        vim.cmd(command)
    else
        vim.cmd("DiffviewClose")
    end
end

-- Working tree diff
map("n", "<leader>gd", function()
    toggle_diffview("DiffviewOpen")
end, {
    desc = "Toggle Git diff",
})

-- Repository history
map("n", "<leader>gh", function()
    toggle_diffview("DiffviewFileHistory")
end, {
    desc = "Toggle Git history",
})

-- Current file history
map("n", "<leader>gH", function()
    toggle_diffview("DiffviewFileHistory %")
end, {
    desc = "Toggle current file history",
})
