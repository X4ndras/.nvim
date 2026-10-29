-- Saved workspaces: one JSON file per workspace.
--
-- File format. Groups are optional; most projects just go in "projects".
--   {
--     "name": "Work",
--     "projects": ["~/Work/inhouse", "~/Coding/eyeon"],
--     "groups": [
--       { "name": "gcs", "projects": ["~/Work/gcs/tooling", "~/Work/gcs/kubernetes"] }
--     ]
--   }
-- The shape `"groups": { "gcs": [ ... ] }` is also accepted when reading.

local M = {}

local uv = vim.uv

M.dir = vim.fn.stdpath("data") .. "/workspaces"
local current_file = M.dir .. "/.current"

local function ensure_dir()
  vim.fn.mkdir(M.dir, "p")
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local text = fd:read("*a")
  fd:close()
  return text
end

local function write_file(path, text)
  ensure_dir()
  local tmp = path .. ".tmp"
  local fd = assert(io.open(tmp, "w"))
  fd:write(text)
  fd:close()
  assert(uv.fs_rename(tmp, path))
end

local function file_for(name)
  return M.dir .. "/" .. name:gsub("[/\\]", "_") .. ".json"
end

--- Absolute path with `~` expanded and no trailing slash.
function M.normalize(path)
  path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
  return (path:gsub("(.)/$", "%1"))
end

--- Shorten a path for display / storage (`/Users/me/x` -> `~/x`).
function M.shorten(path)
  return vim.fn.fnamemodify(path, ":~")
end

local function decode(name, text)
  local ok, data = pcall(vim.json.decode, text)
  if not ok or type(data) ~= "table" then
    vim.notify("workspace: could not parse " .. file_for(name), vim.log.levels.ERROR)
    return nil
  end

  local ws = { name = data.name or name, projects = data.projects or {}, groups = {} }
  local groups = data.groups or {}

  if vim.islist(groups) then
    for _, g in ipairs(groups) do
      table.insert(ws.groups, { name = g.name, projects = g.projects or {} })
    end
  else
    local names = vim.tbl_keys(groups)
    table.sort(names)
    for _, gname in ipairs(names) do
      table.insert(ws.groups, { name = gname, projects = groups[gname] })
    end
  end

  for i, p in ipairs(ws.projects) do
    ws.projects[i] = M.normalize(p)
  end
  for _, g in ipairs(ws.groups) do
    for i, p in ipairs(g.projects) do
      g.projects[i] = M.normalize(p)
    end
  end

  return ws
end

function M.list()
  ensure_dir()
  local names = {}
  for file, kind in vim.fs.dir(M.dir) do
    if kind == "file" and file:match("%.json$") then
      table.insert(names, (file:gsub("%.json$", "")))
    end
  end
  table.sort(names)
  return names
end

function M.load(name)
  local text = read_file(file_for(name))
  return text and decode(name, text) or nil
end

function M.save(ws)
  local out = { name = ws.name, projects = vim.tbl_map(M.shorten, ws.projects), groups = {} }
  for _, g in ipairs(ws.groups) do
    local projects = {}
    for _, p in ipairs(g.projects) do
      table.insert(projects, M.shorten(p))
    end
    table.insert(out.groups, { name = g.name, projects = projects })
  end
  -- Written by hand so the keys keep a readable order.
  local enc = vim.json.encode
  local function list(items, indent)
    if #items == 0 then
      return "[]"
    end
    local lines = {}
    for _, p in ipairs(items) do
      table.insert(lines, indent .. "  " .. enc(p))
    end
    return "[\n" .. table.concat(lines, ",\n") .. "\n" .. indent .. "]"
  end
  local groups = {}
  for _, g in ipairs(out.groups) do
    table.insert(
      groups,
      ('    { "name": %s, "projects": %s }'):format(enc(g.name), list(g.projects, "    "))
    )
  end
  local text = ('{\n  "name": %s,\n  "projects": %s,\n  "groups": %s\n}\n'):format(
    enc(out.name),
    list(out.projects, "  "),
    #groups == 0 and "[]" or ("[\n" .. table.concat(groups, ",\n") .. "\n  ]")
  )
  assert(pcall(vim.json.decode, text))
  write_file(file_for(ws.name), text)
end

function M.delete(name)
  os.remove(file_for(name))
end

function M.get_current_name()
  local text = read_file(current_file)
  return text and vim.trim(text) ~= "" and vim.trim(text) or nil
end

function M.set_current_name(name)
  write_file(current_file, (name or "") .. "\n")
end

-- Helpers that operate on an in-memory workspace table -----------------------

function M.find_group(ws, name)
  for i, g in ipairs(ws.groups) do
    if g.name == name then
      return g, i
    end
  end
end

--- Returns the list containing `path` (the workspace's top-level project list
--- or a group), and the index within it.
function M.find_project(ws, path)
  for i, p in ipairs(ws.projects) do
    if p == path then
      return ws, i
    end
  end
  for _, g in ipairs(ws.groups) do
    for i, p in ipairs(g.projects) do
      if p == path then
        return g, i
      end
    end
  end
end

function M.projects(ws)
  local out = vim.list_slice(ws.projects or {})
  for _, g in ipairs(ws.groups) do
    vim.list_extend(out, g.projects)
  end
  return out
end

return M
