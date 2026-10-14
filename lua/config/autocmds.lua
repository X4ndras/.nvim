local file_sync = vim.api.nvim_create_augroup("nevoid_file_sync", {
  clear = true,
})

-- File watchers should handle most external changes. These events provide a
-- fallback for atomic replacements and changes that were not observed
-- immediately.
vim.api.nvim_create_autocmd({
  "FocusGained",
  "BufEnter",
  "CursorHold",
  "CursorHoldI",
}, {
  group = file_sync,
  callback = function()
    if vim.fn.getcmdwintype() ~= "" then
      return
    end

    vim.cmd("checktime")
  end,
})
