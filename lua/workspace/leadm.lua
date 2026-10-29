-- leadm entries for workspaces.
--
--   M.submenu   "Workspace" submenu for the main <leader>m menu
--   M.menus     buffer menus: the workspace tree (depends on the node under
--               the cursor) and the regular Neo-tree file tree

local M = {}

local function ws()
  return require("workspace")
end

local function state()
  return require("neo-tree.sources.manager").get_state_for_window()
end

--- Run a workspace tree command on the node under the cursor.
local function cmd(name)
  return function()
    require("workspace.explorer.commands")[name](state())
  end
end

local sep = { separator = true, name = "󰇘 ──── 󰇘", hl = "Comment" }

local function general()
  local items = {
    { name = "Add project…", bind = "a", fn = cmd("workspace_add_project") },
    { name = "New group…", bind = "G", fn = cmd("workspace_add_group") },
    { name = "Toggle hidden files", bind = "H", fn = cmd("toggle_hidden") },
    { name = "Refresh", bind = "R", fn = cmd("refresh") },
    sep,
    { name = "Switch workspace…", bind = "s", fn = ws().pick_workspace },
    { name = "New workspace…", bind = "n", fn = ws().create },
    { name = "Edit workspace file", bind = "E", fn = function() vim.cmd("Workspace edit") end },
  }
  return items
end

--- Actions for the node under the cursor in the workspace tree.
local function tree_actions()
  local context = require("workspace.explorer.commands").context(state())
  local items = {}
  local function add(list)
    vim.list_extend(items, list)
  end

  if context == "project" then
    add({
      { name = "Remove from workspace", bind = "x", fn = cmd("workspace_remove_project") },
      { name = "Move to group…", bind = "m", fn = cmd("workspace_move_project") },
    })
  elseif context == "group" then
    add({
      { name = "Rename group…", bind = "r", fn = cmd("workspace_rename_group") },
      { name = "Remove group (keeps projects)", bind = "x", fn = cmd("workspace_remove_group") },
    })
  elseif context == "file" or context == "dir" then
    add({
      { name = "Remove this project from workspace", bind = "x", fn = cmd("workspace_remove_project") },
    })
  end

  if #items > 0 then
    table.insert(items, sep)
  end
  add(general())
  return items
end

local function filesystem_actions()
  local items = {
    { name = "Add folder to workspace", bind = "a", fn = ws().add_from_filesystem_tree },
  }
  if not ws().current() then
    table.insert(items, { name = "New workspace…", bind = "n", fn = ws().create })
  end
  vim.list_extend(items, {
    { name = "Switch workspace…", bind = "s", fn = ws().pick_workspace },
    { name = "Workspace tree", bind = "e", fn = function() vim.cmd("Neotree workspace") end },
  })
  return items
end

M.submenu = {
  name = "Workspace",
  bind = "w",
  actions = function()
    local items = {
      { name = "Toggle workspace tree", bind = "e", fn = ws().toggle_tree },
      { name = "Switch workspace…", bind = "s", fn = ws().pick_workspace },
      { name = "New workspace…", bind = "n", fn = ws().create },
    }
    local last = not ws().current() and ws().last()
    if last then
      table.insert(items, 2, { name = "Reopen " .. last, bind = "l", fn = ws().reopen_last })
    end
    if ws().current() then
      vim.list_extend(items, {
        { name = "Add project…", bind = "a", fn = function() ws().pick_project() end },
        { name = "Add current folder", bind = "c", fn = function() ws().add_project(vim.fn.getcwd()) end },
        { name = "Remove project…", bind = "x", fn = function() ws().remove_project_prompt() end },
        { name = "Edit workspace file", bind = "E", fn = function() vim.cmd("Workspace edit") end },
        { name = "Close workspace", bind = "q", fn = ws().close },
      })
    end
    table.insert(items, sep)
    table.insert(items, {
      name = "Plain file tree",
      bind = "f",
      fn = function() vim.cmd("Neotree toggle reveal filesystem") end,
    })
    return items
  end,
}

M.menus = {
  workspace_tree = {
    match = function(buf)
      return vim.b[buf].neo_tree_source == "workspace"
    end,
    inherit = false,
    actions = tree_actions,
  },
  workspace_zfiletree = {
    match = function(buf)
      return vim.b[buf].neo_tree_source == "filesystem"
    end,
    inherit = false,
    actions = filesystem_actions,
  },
}

return M
