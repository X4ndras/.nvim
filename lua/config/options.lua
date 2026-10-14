vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.wrap = false

-- column line at stop 80
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- React promptly to externally changed files and CursorHold-based behavior.
vim.opt.autoread = true
vim.opt.updatetime = 250


-- spelling
vim.api.nvim_create_autocmd('BufAdd', {
    callback = function()
        vim.opt.spell = true
        vim.opt.spelllang = 'en_us,de'
    end
})

-- vim.opt.pumheight = 20
-- vim.opt.showmode = false
-- vim.opt.wrap = false
-- vim.opt.signcolumn = 'yes'
-- vim.opt.laststatus = 3

