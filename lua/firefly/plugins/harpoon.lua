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



local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new(
        require("telescope.themes").get_dropdown{},
    {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({
        }),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end)
--vim.keymap.set("n", "<leader>l", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end)

vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)

vim.keymap.set("n", "<leader>hh", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open Harpoon window" })

vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end,
    { desc = "Clear Harpoon list" })
