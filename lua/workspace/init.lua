-- Virtual multi-root workspaces for Neo-tree.
--
-- A workspace is a named list of project folders that stay where they are on
-- disk. Projects can optionally be put into groups. See store.lua for the
-- file format and workspace/leadm.lua for the menu entries.
--
--   :Workspace                        toggle the workspace tree
--   :Workspace new <name>             create and switch to a workspace
--   :Workspace switch [name]          switch (saves/restores editor sessions)
--   :Workspace add [path]             add a project (folder browser without a path)
--   :Workspace remove [path]          remove a project (files are untouched)
--   :Workspace move [path] [group]    put a project into a group
--   :Workspace group add|rename|remove <name> [new]
--   :Workspace delete <name>          delete a saved workspace definition
--   :Workspace edit                   open the workspace JSON file
--   :Workspace close                  save the session and leave the workspace

local store = require("workspace.store")

local M = {}

M.config = {
  -- Save the editor session per workspace and restore it when switching.
  sessions = true,
  -- Reopen the last workspace when Neovim starts without files. Off: Neovim
  -- starts plain and you open a workspace yourself (<leader>m w s / l).
  restore_on_startup = false,
}

local current -- the loaded workspace table
local session_active = false -- only save sessions we restored or started

local session_dir = vim.fn.stdpath("state") .. "/workspaces/sessions"

local NO_GROUP = "(no group)"

local function notify(msg, level)
  vim.notify("workspace: " .. msg, level or vim.log.levels.INFO)
end

local function refresh_views()
  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if ok then
    require("workspace.repos").forget()
    require("workspace.explorer").git_changed()
  end
end

local function save()
  store.save(current)
  refresh_views()
end

local function require_ws()
  if not current then
    notify("no workspace open. <leader>m → Workspace → New / Switch", vim.log.levels.WARN)
    return false
  end
  return true
end

function M.current()
  return current
end

-- Tree ------------------------------------------------------------------------

local function tree_windows(tab)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab or 0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      table.insert(wins, { win = win, source = vim.b[buf].neo_tree_source })
    end
  end
  return wins
end

function M.tree_open()
  for _, w in ipairs(tree_windows()) do
    if w.source == "workspace" then
      return true
    end
  end
  return false
end

function M.toggle_tree()
  vim.cmd("Neotree toggle workspace")
end

-- Sessions --------------------------------------------------------------------

local function session_file(name)
  return session_dir .. "/" .. name:gsub("[/\\]", "_") .. ".vim"
end

--- Close Neo-tree windows in every tab (they don't restore well from a
--- session). Returns whether the workspace tree was open.
local function close_trees()
  local had_tree = false
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, w in ipairs(tree_windows(tab)) do
      had_tree = had_tree or w.source == "workspace"
      if #vim.api.nvim_tabpage_list_wins(tab) > 1 then
        pcall(vim.api.nvim_win_close, w.win, true)
      end
    end
  end
  return had_tree
end

function M.save_session()
  if not (M.config.sessions and current and session_active) then
    return
  end
  vim.fn.mkdir(session_dir, "p")
  local had_tree = close_trees()
  vim.g.WorkspaceTree = had_tree and 1 or 0

  local saved = vim.o.sessionoptions
  local opts = vim.tbl_filter(function(o)
    return o ~= "blank" and o ~= "options" and o ~= "localoptions"
  end, vim.split(saved, ","))
  table.insert(opts, "globals")
  vim.o.sessionoptions = table.concat(opts, ",")
  local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(session_file(current.name)))
  vim.o.sessionoptions = saved
  if not ok then
    notify("could not save session: " .. tostring(err), vim.log.levels.ERROR)
  end
  return had_tree
end

local function restore_session(name)
  local file = session_file(name)
  vim.g.WorkspaceTree = 1
  if M.config.sessions and vim.uv.fs_stat(file) then
    local ok, err = pcall(vim.cmd, "silent! source " .. vim.fn.fnameescape(file))
    if not ok then
      notify("could not restore session: " .. tostring(err), vim.log.levels.WARN)
    end
  end
  session_active = true
  if vim.g.WorkspaceTree ~= 0 then
    vim.schedule(function()
      vim.cmd("Neotree show workspace")
    end)
  end
end

--- Returns false if the user cancelled because of unsaved buffers.
local function confirm_unsaved()
  local modified = vim.tbl_filter(function(b)
    return vim.bo[b].modified and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  if #modified == 0 then
    return true
  end
  local choice = vim.fn.confirm(#modified .. " buffer(s) have unsaved changes.", "&Save all\n&Cancel", 2)
  if choice == 1 then
    vim.cmd("silent! wall")
    return true
  end
  return false
end

-- Switching -------------------------------------------------------------------

--- Make `name` the current workspace. Saves the old session and restores the
--- new one unless `opts.keep_buffers` is set.
function M.switch(name, opts)
  opts = opts or {}
  local ws = store.load(name)
  if not ws then
    notify("no workspace named " .. name, vim.log.levels.ERROR)
    return
  end
  if current and current.name == name and session_active then
    vim.cmd("Neotree show workspace")
    return
  end

  if not opts.keep_buffers then
    if not confirm_unsaved() then
      return
    end
    M.save_session()
    close_trees()
    vim.cmd("silent! tabonly | silent! only | silent! %bwipeout")
  end

  current = ws
  store.set_current_name(name)
  refresh_views()

  if opts.keep_buffers then
    session_active = true
    vim.cmd("Neotree show workspace")
  else
    restore_session(name)
  end
  notify("opened " .. name)
end

function M.create(name)
  name = name and vim.trim(name) or ""
  if name == "" then
    vim.ui.input({ prompt = "New workspace name: " }, function(input)
      if input and vim.trim(input) ~= "" then
        M.create(input)
      end
    end)
    return
  end
  if not store.load(name) then
    store.save({ name = name, projects = {}, groups = {} })
  end
  -- The first workspace keeps the buffers you have open.
  M.switch(name, { keep_buffers = current == nil })
end

function M.close()
  if not current then
    return
  end
  M.save_session()
  close_trees()
  current = nil
  session_active = false
  store.set_current_name(nil)
end

function M.delete(name)
  if current and current.name == name then
    M.close()
  end
  store.delete(name)
  os.remove(session_file(name))
  notify("deleted workspace " .. name .. " (project folders are untouched)")
end

--- The workspace that was open last time, if it still exists.
function M.last()
  local name = store.get_current_name()
  return name and store.load(name) and name or nil
end

function M.reopen_last()
  local name = M.last()
  if name then
    M.switch(name)
  else
    notify("no previous workspace", vim.log.levels.INFO)
  end
end

function M.pick_workspace()
  local last = M.last()
  local items = store.list()
  -- Last used first.
  table.sort(items, function(a, b)
    if (a == last) ~= (b == last) then
      return a == last
    end
    return a < b
  end)
  vim.list_extend(items, { "+ New workspace…" })
  vim.ui.select(items, {
    prompt = "Workspace",
    format_item = function(item)
      if current and item == current.name then
        return item .. "  (current)"
      elseif item == last then
        return item .. "  (last)"
      end
      return item
    end,
  }, function(choice)
    if not choice then
      return
    elseif choice == "+ New workspace…" then
      M.create()
    else
      M.switch(choice)
    end
  end)
end

-- Groups (optional) -----------------------------------------------------------

function M.add_group(name)
  if not require_ws() then
    return
  end
  if not store.find_group(current, name) then
    table.insert(current.groups, { name = name, projects = {} })
    save()
  end
  return name
end

function M.add_group_prompt(callback)
  if not require_ws() then
    return
  end
  vim.ui.input({ prompt = "New group name: " }, function(input)
    if input and vim.trim(input) ~= "" then
      local name = M.add_group(vim.trim(input))
      if callback then
        callback(name)
      end
    end
  end)
end

function M.rename_group(old, new)
  local g = require_ws() and store.find_group(current, old)
  if not g then
    return
  end
  if store.find_group(current, new) then
    notify("group " .. new .. " already exists", vim.log.levels.ERROR)
    return
  end
  g.name = new
  save()
end

function M.rename_group_prompt(old)
  vim.ui.input({ prompt = "Rename group: ", default = old }, function(input)
    if input and vim.trim(input) ~= "" and input ~= old then
      M.rename_group(old, vim.trim(input))
    end
  end)
end

--- Remove a group. Its projects stay in the workspace, ungrouped.
function M.remove_group(name)
  local g, idx
  if require_ws() then
    g, idx = store.find_group(current, name)
  end
  if not g then
    return
  end
  vim.list_extend(current.projects, g.projects)
  table.remove(current.groups, idx)
  save()
end

-- Projects --------------------------------------------------------------------

--- Add a project folder; `group` is optional.
function M.add_project(path, group)
  if not require_ws() then
    return
  end
  path = store.normalize(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "directory" then
    notify(path .. " is not a folder", vim.log.levels.ERROR)
    return
  end
  for _, p in ipairs(store.projects(current)) do
    if p == path then
      notify(store.shorten(path) .. " is already in the workspace")
      return
    end
    local utils = require("neo-tree.utils")
    if utils.is_subpath(p, path) or utils.is_subpath(path, p) then
      notify(
        store.shorten(path) .. " overlaps with " .. store.shorten(p) .. ", which is already in the workspace",
        vim.log.levels.WARN
      )
      return
    end
  end
  if group and group ~= NO_GROUP then
    M.add_group(group)
    table.insert(store.find_group(current, group).projects, path)
  else
    table.insert(current.projects, path)
  end
  save()
  notify("added " .. store.shorten(path))
end

function M.remove_project(path)
  if not require_ws() then
    return
  end
  path = store.normalize(path)
  local list, idx = store.find_project(current, path)
  if not list then
    notify(store.shorten(path) .. " is not in this workspace", vim.log.levels.WARN)
    return
  end
  local choice = vim.fn.confirm(
    "Remove " .. vim.fs.basename(path) .. " from the workspace?\nFiles on disk are not touched.",
    "&Remove\n&Cancel",
    2
  )
  if choice == 1 then
    table.remove(list.projects, idx)
    save()
  end
end

--- Move a project into `group`, or out of any group with "(no group)"/nil.
function M.move_project(path, group)
  if not require_ws() then
    return
  end
  path = store.normalize(path)
  local list, idx = store.find_project(current, path)
  if not list then
    return
  end
  table.remove(list.projects, idx)
  if group and group ~= NO_GROUP then
    M.add_group(group)
    table.insert(store.find_group(current, group).projects, path)
  else
    table.insert(current.projects, path)
  end
  save()
end

--- Pick a project of the workspace and remove it (files are untouched).
function M.remove_project_prompt()
  if not require_ws() then
    return
  end
  local projects = store.projects(current)
  if #projects == 0 then
    notify("this workspace has no projects")
    return
  end
  vim.ui.select(projects, {
    prompt = "Remove project from " .. current.name,
    format_item = store.shorten,
  }, function(choice)
    if choice then
      M.remove_project(choice)
    end
  end)
end

function M.move_project_prompt(path)
  if not require_ws() then
    return
  end
  local items = { NO_GROUP }
  for _, g in ipairs(current.groups) do
    table.insert(items, g.name)
  end
  table.insert(items, "+ New group…")
  vim.ui.select(items, { prompt = "Move " .. vim.fs.basename(path) .. " to" }, function(choice)
    if not choice then
      return
    elseif choice == "+ New group…" then
      M.add_group_prompt(function(group)
        M.move_project(path, group)
      end)
    else
      M.move_project(path, choice)
    end
  end)
end

-- Folder browser --------------------------------------------------------------

--- Where the folder browser starts: next to the last project added, else cwd.
local function browse_start()
  local projects = current and store.projects(current) or {}
  local last = projects[#projects]
  if last and vim.uv.fs_stat(last) then
    return vim.fs.dirname(last)
  end
  return vim.fn.getcwd()
end

local function subdirs(dir, show_hidden)
  local out = {}
  local handle = vim.uv.fs_scandir(dir)
  while handle do
    local name, kind = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if kind == "link" then
      local stat = vim.uv.fs_stat(dir .. "/" .. name)
      kind = stat and stat.type
    end
    if kind == "directory" and (show_hidden or name:sub(1, 1) ~= ".") then
      local path = (dir == "/" and "" or dir) .. "/" .. name
      table.insert(out, { path = path, name = name, repo = vim.uv.fs_stat(path .. "/.git") ~= nil })
    end
  end
  table.sort(out, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
  return out
end

--- Browse folders anywhere on disk and add them as projects.
---   <CR>    open the folder (on "Add …": add the folder you're in)
---   <C-a>   add the highlighted folder(s) (<Tab> marks several)
---   <C-h>   parent folder      <C-.> show hidden folders
---   typing ~/path or /path and <CR> jumps there
function M.pick_project(opts)
  opts = opts or {}
  if not require_ws() then
    return
  end

  local function finish(paths)
    for _, p in ipairs(paths) do
      M.add_project(p, opts.group)
    end
  end

  local ok = pcall(require, "telescope")
  if not ok then
    vim.ui.input({ prompt = "Project folder: ", completion = "dir", default = browse_start() .. "/" }, function(input)
      if input and input ~= "" then
        finish({ input })
      end
    end)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local dir = browse_start()
  local show_hidden = false

  local function make_finder()
    local results = {
      { kind = "add", path = dir },
    }
    if dir ~= "/" then
      table.insert(results, { kind = "up", path = vim.fs.dirname(dir) })
    end
    for _, d in ipairs(subdirs(dir, show_hidden)) do
      table.insert(results, { kind = "dir", path = d.path, name = d.name, repo = d.repo })
    end
    return finders.new_table({
      results = results,
      entry_maker = function(item)
        local display, ordinal
        if item.kind == "add" then
          display = "＋ Add " .. store.shorten(item.path)
          ordinal = "" -- stays visible while filtering
        elseif item.kind == "up" then
          display = "  ../"
          ordinal = ".."
        else
          display = (item.repo and " " or " ") .. item.name .. "/"
          ordinal = item.name
        end
        return { value = item, display = display, ordinal = ordinal }
      end,
    })
  end

  local function go(bufnr, path)
    dir = store.normalize(path)
    local picker = action_state.get_current_picker(bufnr)
    picker.prompt_border:change_title(store.shorten(dir))
    picker:refresh(make_finder(), { reset_prompt = true })
  end

  local function selected_paths(bufnr)
    local picker = action_state.get_current_picker(bufnr)
    local paths = {}
    for _, entry in ipairs(picker:get_multi_selection()) do
      if entry.value.kind ~= "up" then
        table.insert(paths, entry.value.path)
      end
    end
    if #paths == 0 then
      local entry = action_state.get_selected_entry()
      if entry and entry.value.kind ~= "up" then
        paths = { entry.value.path }
      end
    end
    return paths
  end

  pickers
    .new({}, {
      prompt_title = store.shorten(dir),
      results_title = "Add project to " .. current.name .. (opts.group and (" / " .. opts.group) or ""),
      finder = make_finder(),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(bufnr, map)
        actions.select_default:replace(function()
          local typed = action_state.get_current_line()
          if typed:match("^[~/]") then
            local path = store.normalize(typed)
            if vim.fn.isdirectory(path) == 1 then
              go(bufnr, path)
            else
              notify(typed .. " is not a folder", vim.log.levels.WARN)
            end
            return
          end
          local entry = action_state.get_selected_entry()
          if not entry then
            return
          end
          if entry.value.kind == "add" then
            actions.close(bufnr)
            vim.schedule(function()
              finish({ entry.value.path })
            end)
          else
            go(bufnr, entry.value.path)
          end
        end)

        local function add_selected()
          local paths = selected_paths(bufnr)
          actions.close(bufnr)
          vim.schedule(function()
            finish(paths)
          end)
        end
        local function up()
          if dir ~= "/" then
            go(bufnr, vim.fs.dirname(dir))
          end
        end
        local function toggle_hidden()
          show_hidden = not show_hidden
          go(bufnr, dir)
        end

        map({ "i", "n" }, "<C-a>", add_selected)
        map({ "i", "n" }, "<C-h>", up)
        map({ "i", "n" }, "<C-.>", toggle_hidden)
        map("i", "<BS>", function()
          if action_state.get_current_line() == "" then
            up()
          else
            vim.api.nvim_feedkeys(vim.keycode("<BS>"), "n", false)
          end
        end)
        return true
      end,
    })
    :find()
end

--- Add the folder under the cursor in a regular Neo-tree file tree.
function M.add_from_filesystem_tree()
  local state = require("neo-tree.sources.manager").get_state_for_window()
  local node = state and state.tree and state.tree:get_node()
  if not node or not node.path then
    return
  end
  local path = node.type == "directory" and node.path or vim.fs.dirname(node.path)
  if not current then
    notify("open or create a workspace first", vim.log.levels.WARN)
    return
  end
  M.add_project(path)
end

-- :Workspace command ----------------------------------------------------------

local subcommands = {}

subcommands.new = function(args)
  M.create(table.concat(args, " "))
end

subcommands.switch = function(args)
  if args[1] then
    M.switch(args[1])
  else
    M.pick_workspace()
  end
end

subcommands.add = function(args)
  if args[1] then
    M.add_project(args[1], args[2])
  else
    M.pick_project()
  end
end

subcommands.remove = function(args)
  M.remove_project(args[1] or vim.fn.getcwd())
end

subcommands.move = function(args)
  local path = args[1] or vim.fn.getcwd()
  if args[2] then
    M.move_project(path, args[2])
  else
    M.move_project_prompt(path)
  end
end

subcommands.group = function(args)
  local action, name, new = args[1], args[2], args[3]
  if action == "add" and name then
    M.add_group(name)
  elseif action == "rename" and name and new then
    M.rename_group(name, new)
  elseif action == "remove" and name then
    M.remove_group(name)
  else
    notify("usage: :Workspace group add|rename|remove <name> [new name]", vim.log.levels.WARN)
  end
end

subcommands.delete = function(args)
  if not args[1] then
    notify("usage: :Workspace delete <name>", vim.log.levels.WARN)
    return
  end
  if vim.fn.confirm("Delete workspace " .. args[1] .. "?", "&Delete\n&Cancel", 2) == 1 then
    M.delete(args[1])
  end
end

subcommands.edit = function()
  if require_ws() then
    vim.cmd.edit(vim.fn.fnameescape(store.dir .. "/" .. current.name .. ".json"))
  end
end

subcommands.close = function()
  M.close()
end

subcommands.toggle = function()
  M.toggle_tree()
end

local function complete(arglead, cmdline)
  local words = vim.split(cmdline, "%s+", { trimempty = true })
  local n = #words + (cmdline:match("%s$") and 1 or 0)
  local function filter(list)
    return vim.tbl_filter(function(s)
      return vim.startswith(s, arglead)
    end, list)
  end
  local groups = {}
  for _, g in ipairs(current and current.groups or {}) do
    table.insert(groups, g.name)
  end

  if n == 2 then
    return filter(vim.tbl_keys(subcommands))
  end
  local sub = words[2]
  if (sub == "switch" or sub == "delete") and n == 3 then
    return filter(store.list())
  elseif sub == "add" and n == 3 then
    return vim.fn.getcompletion(arglead, "dir")
  elseif (sub == "remove" or sub == "move") and n == 3 then
    return filter(vim.tbl_map(store.shorten, current and store.projects(current) or {}))
  elseif (sub == "add" or sub == "move") and n == 4 then
    return filter(groups)
  elseif sub == "group" then
    if n == 3 then
      return filter({ "add", "rename", "remove" })
    elseif n == 4 then
      return filter(groups)
    end
  end
  return {}
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("Workspace", function(cmd)
    local args = vim.deepcopy(cmd.fargs)
    local sub = table.remove(args, 1) or "toggle"
    if not subcommands[sub] then
      notify("unknown subcommand " .. sub, vim.log.levels.ERROR)
      return
    end
    subcommands[sub](args)
  end, { nargs = "*", complete = complete, desc = "Manage workspaces" })

  local group = vim.api.nvim_create_augroup("workspace", { clear = true })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      M.save_session()
    end,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      if current then
        require("workspace.explorer").git_changed()
      end
    end,
  })

  -- Neovim starts without a workspace. With restore_on_startup, the last one
  -- is reopened, but only when Neovim was started without files.
  local name = M.config.restore_on_startup and M.last()
  if name then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      nested = true,
      once = true,
      callback = function()
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and not vim.bo.modified then
          current = store.load(name)
          restore_session(name)
        end
      end,
    })
  end
end

return M
