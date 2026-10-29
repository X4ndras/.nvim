local M = {}

function M.diagnose()
  vim.diagnostic.open_float({
      scope = "line",
      source = true
  })
end

require("leadm").setup({
  -- "none", "single", "double", "rounded", "solid", "shadow"
  -- heavy, dashed, block, ascii, rule
  border = "rounded",
  -- string to show a window title
  title = false,

  name_width = 28, -- minimum width of the name column
  bind_format = "%s", -- how a key is rendered next to its action
  separator_char = "─",
  submenu_marker = "›", -- drawn behind entries that open a submenu

  -- Workspace tree and Neo-tree file tree get their own menus.
  menus = require("workspace.leadm").menus,


  actions = {
    { name = "Rename Symbol", fn = vim.lsp.buf.rename, bind = "R" },
    { name = "Show Signature Help", fn = vim.lsp.buf.signature_help, bind = "s" },
    { name = "Show References", fn = vim.lsp.buf.references, bind = "r" },
    { name = "Code Action", fn = vim.lsp.buf.code_action, bind = "f" },
    { name = "Inspect", fn = M.diagnose, bind = "e" },
    -- { separator = true },
    -- { separator = true, separator_char = "·" },            -- ······························
    -- { separator = true,             name = "@_/\\_@" }, --            @_/\_@
    { separator = true, name = "󰇘 ──── 󰇘", hl = "Comment" },
    { name = "Goto Definition", fn = vim.lsp.buf.definition, bind = "gd" },
    { name = "Goto Declaration", fn = vim.lsp.buf.declaration, bind = "gD" },
    { name = "Goto Implementation", fn = vim.lsp.buf.implementation, bind = "gi" },
    { separator = true, name = "󰇘 ──── 󰇘", hl = "Comment" },
    { name = "Format Document", fn = function() vim.lsp.buf.format({ async = true }) end, bind = "F" },
    { separator = true, name = "󰇘 ──── 󰇘", hl = "Comment" },
    require("workspace.leadm").submenu,
    {
      name = "Git",
      bind = "g",
      actions = {
        {
          name = "Diff",
          bind = "d",
          fn = function()
            require("workspace.repos").choose(function(repo)
              vim.cmd("DiffviewOpen -C" .. vim.fn.fnameescape(repo))
            end)
          end,
        },
        {
          name = "Status tree",
          bind = "t",
          fn = function()
            require("workspace.repos").choose(function(repo)
              vim.cmd("Neotree git_status dir=" .. vim.fn.fnameescape(repo))
            end)
          end,
        },
        { name = "File", bind = "f", fn = stage_file },
        { name = "Hunk", bind = "h", fn = stage_hunk },
      },
    },
  }
})
