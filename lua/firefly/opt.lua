local os_name = require('luv').os_uname()['sysname']

vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.termguicolors = true
vim.opt.nu = true
vim.opt.mouse = ''
vim.opt.relativenumber = true

vim.opt.timeoutlen = 350

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.pumheight = 20
vim.opt.showmode = false
vim.opt.updatetime = 200


vim.schedule(function ()
    vim.opt.clipboard = 'unnamedplus'
end)

if (os_name == 'Windows_NT') then
    vim.opt.shell = 'powershell.exe'
end

-- for cmp plugin so the sign column does not open and close constantly
vim.opt.signcolumn = 'yes'

vim.opt.laststatus = 3

vim.cmd("setlocal spell spelllang=en_us")

--vim.g.netrw_keepdir = 0
--vim.g.netrw_banner = 1
--vim.g.netrw_winsize = 30
--vim.g.netrw_browse_split = 4
--vim.g.netrw_clipboard = 0
--vim.g.netrw_fastbrowse = 2
