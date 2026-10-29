-- Branch and tag (or short commit, when HEAD has no tag) of the repository
-- at a path, appended to tree root names, e.g. "nvim  revamp  v1.2".
-- Looked up in the background and cached, so drawing the tree never waits
-- on git. The cache goes stale on git events and when Neovim regains focus.

local M = {}

local cache = {} -- path -> { parts = {...}, stale = bool }
local pending = {}

local BRANCH_HL = "Function"
local REF_HL = "NeoTreeDimText"

--- `git log -1 --format=%h%x09%D` → "abc1234\tHEAD -> main, tag: v1, origin/main"
local function parse(out)
  local hash, refs = out:match("^(%x+)\t([^\n]*)")
  if not hash then
    return {}
  end
  local parts = {}
  local branch = refs:match("HEAD %-> ([^,]+)")
  if branch then
    table.insert(parts, { text = "  " .. branch, highlight = BRANCH_HL })
  end
  local tag = refs:match("tag: ([^,]+)")
  if tag then
    table.insert(parts, { text = "  " .. tag, highlight = REF_HL })
  else
    table.insert(parts, { text = "  " .. hash, highlight = REF_HL })
  end
  return parts
end

local function same(a, b)
  if #a ~= #b then
    return false
  end
  for i = 1, #a do
    if a[i].text ~= b[i].text then
      return false
    end
  end
  return true
end

local function redraw()
  local manager = require("neo-tree.sources.manager")
  for _, source in ipairs({ "filesystem", "workspace" }) do
    pcall(manager.redraw, source)
  end
end

local function fetch(path)
  pending[path] = true
  vim.system(
    { "git", "-C", path, "log", "-1", "--format=%h%x09%D" },
    { text = true },
    vim.schedule_wrap(function(res)
      pending[path] = nil
      local parts = res.code == 0 and parse(res.stdout or "") or {}
      local old = cache[path]
      cache[path] = { parts = parts }
      if not old or not same(old.parts, parts) then
        redraw()
      end
    end)
  )
end

--- The cached branch/ref pieces for `path` (empty until the first lookup
--- finishes). Starts a lookup when there is none or it is stale.
function M.get(path)
  local entry = cache[path]
  if (not entry or entry.stale) and not pending[path] then
    fetch(path)
  end
  return entry and entry.parts or {}
end

--- Neo-tree component output for a name, with the branch/ref of `path` added.
function M.decorate(name, path)
  local parts = M.get(path)
  if #parts == 0 then
    return name
  end
  local out = name.text and { name } or vim.list_extend({}, name)
  return vim.list_extend(out, vim.deepcopy(parts))
end

--- Look everything up again on the next draw; keep showing the old value
--- until then so the header doesn't flicker.
function M.invalidate()
  for _, entry in pairs(cache) do
    entry.stale = true
  end
  redraw()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("workspace_head", { clear = true })
  -- Checkouts and commits usually happen in a terminal outside Neovim, or in
  -- a shell or terminal buffer inside it.
  vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost", "TermLeave", "DirChanged" }, {
    group = group,
    callback = M.invalidate,
  })
  local events = require("neo-tree.events")
  events.subscribe({ id = "workspace_head", event = events.GIT_EVENT, handler = M.invalidate })
end

return M
