-- Commands of the "workspace" Neo-tree source. The workspace ones are also
-- what the leadm menu calls (see workspace/leadm.lua).

local cc = require("neo-tree.sources.common.commands")
local utils = require("neo-tree.utils")
local manager = require("neo-tree.sources.manager")
local explorer = require("workspace.explorer")

local M = {}

local refresh = utils.wrap(manager.refresh, "workspace")
local redraw = utils.wrap(manager.redraw, "workspace")
local toggle_directory = function(node)
  explorer.toggle_directory(manager.get_state("workspace"), node)
end

local function ws()
  return require("workspace")
end

local function notify(msg, level)
  vim.notify("workspace: " .. msg, level or vim.log.levels.INFO)
end

function M.node(state)
  local ok, node = pcall(state.tree.get_node, state.tree)
  return ok and node or nil
end

local function parent(state, node)
  local id = node:get_parent_id()
  return id and state.tree:get_node(id) or nil
end

--- What the cursor is on, for menus: "file", "dir", "project", "group",
--- "section" or nil.
function M.context(state)
  local node = state and state.tree and M.node(state)
  if not node then
    return nil
  end
  local e = node.extra or {}
  if node.type == "group" then
    return "group", node
  elseif e.project then
    return "project", node
  elseif node.type == "directory" and e.project_root then
    return "dir", node
  elseif node.type == "file" and e.project_root then
    return "file", node
  elseif node.type == "section" then
    return "section", node
  end
end

--- True for files and folders inside a project (not a project root, group
--- or the workspace header).
local function in_project(node)
  local e = node and node.extra or {}
  return e.project_root and not e.project and (node.type == "file" or node.type == "directory")
end

local function guard_fs(state)
  local node = M.node(state)
  if in_project(node) then
    return true
  end
  if node and node.extra and node.extra.project then
    notify("that's a project root. <leader>m has Remove from workspace / Move to group.", vim.log.levels.WARN)
  end
  return false
end

local function group_of(state)
  local node = M.node(state)
  while node do
    if node.extra and node.extra.group then
      return node.extra.group
    end
    node = parent(state, node)
  end
end

local function project_of(state)
  local node = M.node(state)
  while node do
    if node.extra and node.extra.project then
      return node
    end
    node = parent(state, node)
  end
end

-- Opening ---------------------------------------------------------------------

local function opener(fn)
  return function(state)
    local node = M.node(state)
    if not node or node.type == "message" or node.type == "missing" then
      return
    end
    fn(state, toggle_directory)
  end
end

M.open = opener(cc.open)
M.open_split = opener(cc.open_split)
M.open_vsplit = opener(cc.open_vsplit)
M.open_tabnew = opener(cc.open_tabnew)
M.open_drop = opener(cc.open_drop)
M.open_tab_drop = opener(cc.open_tab_drop)
M.open_rightbelow_vs = opener(cc.open_rightbelow_vs)
M.open_leftabove_vs = opener(cc.open_leftabove_vs)
M.open_with_window_picker = opener(cc.open_with_window_picker)
M.split_with_window_picker = opener(cc.split_with_window_picker)
M.vsplit_with_window_picker = opener(cc.vsplit_with_window_picker)

M.toggle_node = function(state)
  cc.toggle_node(state, toggle_directory)
end

M.toggle_directory = function(state)
  cc.toggle_directory(state, toggle_directory)
end

M.refresh = function()
  require("workspace.repos").forget()
  explorer.git_changed()
end

M.toggle_hidden = function(state)
  state.ws_show_hidden = not state.ws_show_hidden
  refresh()
end

-- File operations (only inside projects) ------------------------------------

local function folder_op(fn)
  return function(state)
    local node = M.node(state)
    if in_project(node) or (node and node.extra and node.extra.project) then
      fn(state, refresh)
    end
  end
end

local function file_op(fn, cb)
  return function(state)
    if guard_fs(state) then
      fn(state, cb or refresh)
    end
  end
end

M.add = folder_op(cc.add)
M.add_directory = folder_op(cc.add_directory)
M.paste_from_clipboard = folder_op(cc.paste_from_clipboard)
M.delete = file_op(cc.delete)
M.trash = file_op(cc.trash)
M.rename = file_op(cc.rename)
M.rename_basename = file_op(cc.rename_basename)
M.copy = file_op(cc.copy)
M.move = file_op(cc.move)
M.copy_to_clipboard = file_op(cc.copy_to_clipboard, redraw)
M.cut_to_clipboard = file_op(cc.cut_to_clipboard, redraw)

M.delete_visual = function(state, selected_nodes)
  for _, node in ipairs(selected_nodes) do
    if not in_project(node) then
      notify("selection contains a project root or group", vim.log.levels.WARN)
      return
    end
  end
  cc.delete_visual(state, selected_nodes, refresh)
end

M.clear_clipboard = function(state)
  cc.clear_clipboard(state)
  redraw()
end

-- Workspace management --------------------------------------------------------

--- Add projects; into the group under the cursor, if any.
M.workspace_add_project = function(state)
  ws().pick_project({ group = state and group_of(state) })
end

M.workspace_add_group = function()
  ws().add_group_prompt()
end

M.workspace_remove_project = function(state)
  local project = project_of(state)
  if project then
    ws().remove_project(project.path)
  end
end

M.workspace_move_project = function(state)
  local project = project_of(state)
  if project then
    ws().move_project_prompt(project.path)
  end
end

M.workspace_rename_group = function(state)
  local group = group_of(state)
  if group then
    ws().rename_group_prompt(group)
  end
end

M.workspace_remove_group = function(state)
  local group = group_of(state)
  if group then
    ws().remove_group(group)
  end
end

cc._add_common_commands(M)

return M
