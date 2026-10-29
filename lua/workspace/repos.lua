-- Finds the Git repositories of each project so Neo-tree's own Git markers
-- work in the workspace tree.
--
-- A project can be a repository, contain several repositories (e.g. ~/Work/gcs
-- holding tooling/, kubernetes/, ...), or sit inside one.

local M = {}

local uv = vim.uv

M.max_depth = 4
M.skip = {
  [".git"] = true,
  node_modules = true,
  vendor = true,
  dist = true,
  build = true,
  target = true,
  [".venv"] = true,
  venv = true,
  [".terraform"] = true,
  __pycache__ = true,
  [".cache"] = true,
}

local by_project = {} -- project path -> list of repo roots

local function has_git(dir)
  return uv.fs_stat(dir .. "/.git") ~= nil
end

local function find_nested(dir, depth, out)
  local handle = uv.fs_scandir(dir)
  if not handle then
    return
  end
  while true do
    local name, kind = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if kind == "directory" and not M.skip[name] then
      local path = dir .. "/" .. name
      if has_git(path) then
        table.insert(out, path)
      end
      if depth < M.max_depth then
        find_nested(path, depth + 1, out)
      end
    end
  end
end

--- Repository roots for a project, cached until `M.forget()`.
function M.for_project(project)
  if by_project[project] then
    return by_project[project]
  end
  local repos = {}
  if has_git(project) then
    table.insert(repos, project)
  end
  find_nested(project, 1, repos)
  if #repos == 0 and uv.fs_stat(project) then
    -- Maybe the project is a folder inside a repository.
    local obj = vim.system({ "git", "-C", project, "rev-parse", "--show-toplevel" }, { text = true }):wait()
    if obj.code == 0 then
      table.insert(repos, vim.trim(obj.stdout))
    end
  end
  by_project[project] = repos
  return repos
end

--- Every repository of the workspace, each listed once.
function M.all(ws)
  local out, seen = {}, {}
  for _, project in ipairs(require("workspace.store").projects(ws)) do
    for _, repo in ipairs(M.for_project(project)) do
      if not seen[repo] then
        seen[repo] = true
        table.insert(out, repo)
      end
    end
  end
  table.sort(out)
  return out
end

--- The repository containing `path` (deepest one wins), or nil.
function M.containing(path)
  if not path or path == "" then
    return nil
  end
  local dir = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
  local obj = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if obj.code == 0 then
    return vim.trim(obj.stdout)
  end
end

--- Call `callback(repo)` with the repository to work on: the one of the
--- current file, else the cwd's, else one picked from the workspace's
--- repositories (or the repos below the cwd when no workspace is open).
function M.choose(callback)
  local repo = M.containing(vim.api.nvim_buf_get_name(0))
  if not repo and vim.bo.filetype == "neo-tree" then
    -- In a tree: use the node under the cursor.
    local state = require("neo-tree.sources.manager").get_state_for_window()
    local node = state and state.tree and state.tree:get_node()
    repo = node and node.path and M.containing(node.path)
  end
  repo = repo or M.containing(vim.fn.getcwd())
  if repo then
    callback(repo)
    return
  end

  local ws = require("workspace").current()
  local list
  if ws then
    list = M.all(ws)
  else
    list = {}
    for _, git_dir in ipairs(vim.fs.find(".git", { path = vim.fn.getcwd(), limit = math.huge })) do
      table.insert(list, vim.fs.dirname(git_dir))
    end
    table.sort(list)
  end
  if #list == 0 then
    vim.notify("No Git repositories found", vim.log.levels.INFO)
    return
  end
  vim.ui.select(list, {
    prompt = "Git repository",
    format_item = function(r)
      return vim.fn.fnamemodify(r, ":~")
    end,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

function M.forget()
  by_project = {}
end

--- Ask Neo-tree to (re)load the Git status of every repository in the
--- workspace. Neo-tree redraws the tree when the results come in.
function M.refresh(ws)
  local git = require("neo-tree.git")
  local seen = {}
  for _, project in ipairs(require("workspace.store").projects(ws)) do
    for _, repo in ipairs(M.for_project(project)) do
      if not seen[repo] then
        seen[repo] = true
        git.status_async(repo, nil, {})
      end
    end
  end
end

return M
