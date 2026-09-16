local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

map("n", "<leader>ws", "<C-w>s")
map("n", "<leader>wv", "<C-w>v")
map("n", "<leader>wq", "<C-w>q")
map("n", "<leader>wc", "<C-w>c")
map("n", "<leader>x", "<cmd>Ex<CR>")

map("n", "<M-h>", "<C-w>h")
map("n", "<M-j>", "<C-w>j")
map("n", "<M-k>", "<C-w>k")
map("n", "<M-l>", "<C-w>l")
 

map("n", "<leader>r", "<cmd>source %<cr>", {
    desc = "Reload current config file",
})

map("v", "<D-c>", '"+y')
map("n", "<D-v>", '"+p')
map("v", "<D-v>", '"+p')
map("i", "<D-v>", '<C-r>+')

-- ESC remap all modes
map({
		"n",
		"i",
		"v",
		"c",
		"o",
		"s",
		"t",
		"x"
	}, "<M-;>", "<ESC>",
	{ noremap = true, silent = true })
