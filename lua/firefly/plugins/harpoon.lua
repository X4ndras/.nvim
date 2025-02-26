local harpoon = require("harpoon")

harpoon:setup({
    settings = {
            save_on_toggle = false,
            sync_on_ui_close = false,

            key = function()
                return vim.loop.cwd()
            end,
        },
})

vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end)
--vim.keymap.set("n", "<leader>l", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end)

vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)

vim.keymap.set("n", "<leader>hh", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end,
    { desc = "Open Harpoon window" })

vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end,
    { desc = "Clear Harpoon list" })
