local os_name = require('luv').os_uname()['sysname']

vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.termguicolors = true
vim.opt.nu = true
vim.opt.mouse = ''
vim.opt.relativenumber = true

vim.opt.timeoutlen = 450

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.pumheight = 20
vim.opt.showmode = false
vim.opt.updatetime = 100
vim.opt.wrap = false
vim.opt.colorcolumn = "80"


vim.schedule(function ()
    vim.opt.clipboard = 'unnamedplus'
end)

if (os_name == 'Windows_NT') then
    vim.opt.shell = 'powershell.exe'
end

-- for cmp plugin so the sign column does not open and close constantly
vim.opt.signcolumn = 'yes'

vim.opt.laststatus = 3

vim.api.nvim_create_autocmd('BufAdd', {
    callback = function()
        vim.opt.spell = true
        vim.opt.spelllang = 'en_us,de'
    end
})
