-- Neo-tree source "workspace": the projects (and optional groups) of the
-- current workspace. Files are opened by their real absolute paths.

local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local events = require("neo-tree.events")
local utils = require("neo-tree.utils")
local repos = require("workspace.repos")

local M = {
  name = "workspace",
  display_name = " 󰉋 Workspace ",
}

local uv = vim.uv

M.hidden = { [".git"] = true, [".DS_Store"] = true }

local ROOT = "ws:root"

local git_dirty = true

local skip_follow_until = 0

--- Don't reveal the next opened file (for a short moment). Used when a file
--- is opened from the tree and the cursor should stay where it is.
function M.skip_follow()
  skip_follow_until = uv.hrtime() + 500 * 1e6
end

--- Mark Git status as stale; the next render fetches it again.
function M.git_changed()
  git_dirty = true
  M.refresh()
end

local function sort_entries(a, b)
  if (a.type == "directory") ~= (b.type == "directory") then
    return a.type == "directory"
  end
  return a.name:lower() < b.name:lower()
end

--- Build the items of a directory. Folders in `open` are scanned recursively,
--- the rest are left unloaded until they are expanded.
local function scan(dir, project_root, open, show_hidden)
  local items = {}
  local handle = uv.fs_scandir(dir)
  if not handle then
    return items
  end
  while true do
    local name, kind = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if show_hidden or not M.hidden[name] then
      local path = dir .. "/" .. name
      local is_link = kind == "link"
      if is_link then
        local stat = uv.fs_stat(path)
        kind = stat and stat.type or "file"
      end
      local item = {
        id = path,
        name = name,
        path = path,
        parent_path = dir,
        type = kind == "directory" and "directory" or "file",
        is_link = is_link,
        link_to = is_link and uv.fs_readlink(path) or nil,
        extra = { project_root = project_root },
      }
      if item.type == "directory" then
        if open[path] then
          item.children = scan(path, project_root, open, show_hidden)
          item.loaded = true
        else
          item.children = {}
          item.loaded = false
        end
      else
        item.ext = name:match("%.([^.]+)$")
      end
      table.insert(items, item)
    end
  end
  table.sort(items, sort_entries)
  return items
end

local function get_state()
  return manager.get_state(M.name)
end

--- Folder ids that should be open on the next render.
local function open_set(state)
  local open = {}
  if state.tree then
    for _, id in ipairs(renderer.get_expanded_nodes(state.tree)) do
      open[id] = true
    end
  else
    for id in pairs(state.ws_open or {}) do
      open[id] = true
    end
  end
  for id in pairs(state.ws_pending_open or {}) do
    open[id] = true
  end
  state.ws_pending_open = {}
  state.ws_open = open
  return open
end

local function project_item(state, path, group, open)
  local exists = uv.fs_stat(path) ~= nil
  local item = {
    id = path,
    name = vim.fs.basename(path),
    path = path,
    type = exists and "directory" or "missing",
    extra = { project_root = path, project = true, group = group },
    children = {},
    loaded = false,
  }
  if exists and open[path] then
    item.children = scan(path, path, open, state.ws_show_hidden)
    item.loaded = true
  end
  return item
end

local function message(id, text, extra)
  return { id = id, name = text, type = "message", extra = extra or {} }
end

local function build_explorer(state, ws, open, expanded)
  local root = {
    id = ROOT,
    name = ws.name,
    type = "section",
    children = {},
    extra = {},
  }

  for _, path in ipairs(ws.projects) do
    table.insert(root.children, project_item(state, path, nil, open))
  end

  for _, group in ipairs(ws.groups) do
    local gid = "ws:group:" .. group.name
    local gnode = {
      id = gid,
      name = group.name,
      type = "group",
      children = {},
      extra = { group = group.name },
    }
    if not state.ws_seen[gid] then
      state.ws_seen[gid] = true
      table.insert(expanded, gid)
    end
    for _, path in ipairs(group.projects) do
      table.insert(gnode.children, project_item(state, path, group.name, open))
    end
    if #gnode.children == 0 then
      table.insert(gnode.children, message(gid .. ":empty", "(empty group)", { group = group.name }))
    end
    table.insert(root.children, gnode)
  end

  if #root.children == 0 then
    table.insert(root.children, message("ws:noproject", "No projects yet. <leader>m → Add project"))
  end
  return root
end

local function build(state, ws)
  local open = open_set(state)
  state.ws_seen = state.ws_seen or {}

  local expanded = {}
  for id in pairs(open) do
    table.insert(expanded, id)
  end
  table.insert(expanded, ROOT)

  if not ws then
    return {
      {
        id = ROOT,
        name = "No workspace",
        type = "section",
        extra = {},
        children = { message("ws:empty", "<leader>m → Workspace → New / Switch") },
      },
    }, expanded
  end

  return { build_explorer(state, ws, open, expanded) }, expanded
end

M.navigate = function(state, path, path_to_reveal, callback, async)
  state.dirty = false
  -- Neo-tree only refreshes states that have a path; the tree itself is not
  -- rooted at any directory.
  state.path = uv.os_homedir()
  local ws = require("workspace").current()
  local nodes, expanded = build(state, ws)
  state.default_expanded_nodes = expanded
  if path_to_reveal then
    renderer.position.set(state, path_to_reveal)
  end
  renderer.show_nodes(nodes, state)

  if ws and git_dirty then
    git_dirty = false
    repos.refresh(ws)
  end

  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

--- Expand or collapse a folder, loading its contents on first open.
M.toggle_directory = function(state, node)
  node = node or state.tree:get_node()
  if not node or node.type ~= "directory" then
    return
  end
  if node.loaded == false then
    state.ws_pending_open = state.ws_pending_open or {}
    state.ws_pending_open[node:get_id()] = true
    M.navigate(state, nil, node:get_id())
  elseif node:is_expanded() then
    node:collapse()
    renderer.redraw(state)
  else
    node:expand()
    renderer.redraw(state)
  end
end

--- Expand every parent folder of `path` and put the cursor on it.
M.reveal = function(path)
  local state = get_state()
  local ws = require("workspace").current()
  if not ws or not path or path == "" then
    return
  end
  local root
  for _, p in ipairs(require("workspace.store").projects(ws)) do
    if utils.is_subpath(p, path) and (not root or #p > #root) then
      root = p
    end
  end
  if not root or not renderer.window_exists(state) then
    return
  end

  -- Already visible: just move the cursor.
  if state.tree then
    local ok, node = pcall(state.tree.get_node, state.tree, path)
    if ok and node then
      local visible = true
      local parent_id = node:get_parent_id()
      while parent_id do
        local parent = state.tree:get_node(parent_id)
        if not parent:is_expanded() then
          visible = false
          break
        end
        parent_id = parent:get_parent_id()
      end
      if visible then
        renderer.focus_node(state, path, true)
        return
      end
    end
  end

  state.ws_pending_open = state.ws_pending_open or {}
  local dir = vim.fs.dirname(path)
  while #dir >= #root do
    state.ws_pending_open[dir] = true
    if dir == root then
      break
    end
    dir = vim.fs.dirname(dir)
  end
  M.navigate(state, nil, path)
end

M.refresh = function()
  manager.refresh(M.name)
end

M.default_config = {
  ws_follow_file = true,
  window = {
    mappings = {
      ["<cr>"] = "open",
      ["H"] = "toggle_hidden",
      ["R"] = "refresh",
    },
  },
  renderers = {
    section = {
      { "icon" },
      { "name" },
    },
    group = {
      { "indent" },
      { "icon" },
      { "name" },
    },
    missing = {
      { "indent" },
      { "icon" },
      { "name" },
    },
    message = {
      { "indent", with_markers = false },
      { "name", highlight = "NeoTreeMessage" },
    },
    directory = {
      { "indent" },
      { "icon" },
      {
        "container",
        content = {
          { "name", zindex = 10 },
          { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
          { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
          { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
        },
      },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "container",
        content = {
          { "name", zindex = 10 },
          { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
          { "modified", zindex = 20, align = "right" },
          { "diagnostics", zindex = 20, align = "right" },
          { "git_status", zindex = 10, align = "right" },
        },
      },
    },
  },
}

M.setup = function(config, global_config)
  manager.subscribe(M.name, {
    event = events.GIT_STATUS_CHANGED,
    handler = function()
      manager.redraw(M.name)
    end,
  })
  manager.subscribe(M.name, { event = events.GIT_EVENT, handler = M.git_changed })
  manager.subscribe(M.name, {
    event = events.VIM_BUFFER_CHANGED,
    handler = function(args)
      if utils.is_real_file(args.afile) then
        M.git_changed()
      end
    end,
  })

  if global_config.enable_diagnostics then
    manager.subscribe(M.name, {
      event = events.STATE_CREATED,
      handler = function(state)
        state.diagnostics_lookup = utils.get_diagnostic_counts()
      end,
    })
    manager.subscribe(M.name, {
      event = events.VIM_DIAGNOSTIC_CHANGED,
      handler = utils.wrap(manager.diagnostics_changed, M.name),
    })
  end

  if global_config.enable_modified_markers then
    manager.subscribe(M.name, {
      event = events.VIM_BUFFER_MODIFIED_SET,
      handler = utils.wrap(manager.opened_buffers_changed, M.name),
    })
  end

  if config.ws_follow_file then
    manager.subscribe(M.name, {
      event = events.VIM_BUFFER_ENTER,
      handler = function(args)
        if uv.hrtime() < skip_follow_until then
          return
        end
        if utils.is_real_file(args.afile) then
          M.reveal(vim.api.nvim_buf_get_name(0))
        end
      end,
    })
  end
end

return M
