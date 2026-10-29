require("diffview").setup({
    use_icons = true,
    watch_index = true,
})

local map = vim.keymap.set

local diffview = require("diffview.lib")


-- Runs in the repo of the current file (or cwd). When neither is a repo,
-- e.g. the cwd is ~/Work, pick one of the workspace's repos.
local function toggle_diffview(command, args)
    if next(diffview.views) ~= nil then
        vim.cmd("DiffviewClose")
        return
    end
    require("workspace.repos").choose(function(repo)
        vim.cmd(command .. " -C" .. vim.fn.fnameescape(repo) .. (args or ""))
    end)
end

-- Working tree diff. With saved workspaces: the changes of every repo in
-- every workspace, grouped by workspace (lua/workspace/diff.lua).
map("n", "<leader>gd", function()
    if next(diffview.views) ~= nil then
        vim.cmd("DiffviewClose")
    elseif #require("workspace.store").list() > 0 then
        require("workspace.diff").toggle()
    else
        toggle_diffview("DiffviewOpen")
    end
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
    toggle_diffview("DiffviewFileHistory", " %")
end, {
    desc = "Toggle current file history",
})
