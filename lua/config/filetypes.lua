local settings = {
  rust = {
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
  },

  lua = {
    shiftwidth = 2,
    tabstop = 2,
  },

  typescript = {
    shiftwidth = 2,
    tabstop = 2,
  },
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local opts = settings[vim.bo.filetype]
    if not opts then
      return
    end

    for option, value in pairs(opts) do
      vim.opt_local[option] = value
      vim.opt_local.expandtab = true
    end
  end,
})
