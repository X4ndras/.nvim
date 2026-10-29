local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

local M = {}

M.icon = function(config, node, state)
  if node.type == "section" then
    return { text = "󰉋 ", highlight = highlights.ROOT_NAME }
  elseif node.type == "group" then
    return { text = (node:is_expanded() and "󰉖 " or "󰉋 "), highlight = "Special" }
  elseif node.type == "missing" then
    return { text = " ", highlight = "DiagnosticError" }
  elseif node.extra and node.extra.project then
    return { text = node:is_expanded() and " " or " ", highlight = highlights.DIRECTORY_ICON }
  end
  return common.icon(config, node, state)
end

M.name = function(config, node, state)
  if node.type == "section" then
    return { text = node.name, highlight = highlights.ROOT_NAME }
  elseif node.type == "group" then
    return { text = node.name, highlight = "Special" }
  elseif node.type == "missing" then
    return { text = node.name .. " (not found)", highlight = highlights.DIM_TEXT }
  elseif node.extra and node.extra.project then
    return require("workspace.head").decorate({ text = node.name, highlight = "Title" }, node.path)
  end
  return common.name(config, node, state)
end

-- How much a status code matters when summing up a folder.
local function weight(code)
  if code:find("U") then
    return 4 -- conflict
  end
  if code == "?" then
    return 1 -- untracked
  end
  local y = code:sub(2, 2)
  if y ~= "." and y ~= " " and y ~= "" then
    return 3 -- unstaged change
  end
  return 2 -- staged change
end

--- Neo-tree's marker, plus one for folders Neo-tree skips: a repository's own
--- root and folders that only contain repositories (e.g. ~/Work/gcs). Those
--- show the most important change of the repositories inside them.
M.git_status = function(config, node, state)
  local marker = common.git_status(config, node, state)
  if node.type ~= "directory" or not node.path or (marker and next(marker)) then
    return marker
  end
  if config.hide_when_expanded and node:is_expanded() then
    return {}
  end
  local project = node.extra and node.extra.project_root
  if not project then
    return {}
  end

  local utils = require("neo-tree.utils")
  local worktrees = require("neo-tree.git").worktrees
  local best_path, best_code, best_weight
  for _, root in ipairs(require("workspace.repos").for_project(project)) do
    if root == node.path or utils.is_subpath(node.path, root) then
      local wt = worktrees[root]
      for path, code in pairs(wt and wt.status or {}) do
        if type(code) == "string" and code ~= "!" then
          local w = weight(code)
          if not best_weight or w > best_weight then
            best_path, best_code, best_weight = path, code, w
          end
        end
      end
    end
  end
  if not best_path then
    return {}
  end
  -- Render it the way Neo-tree renders that file's own status.
  local fake = { type = "file", path = best_path }
  local text = common.git_status(config, setmetatable(fake, { __index = node }), state)
  if text and next(text) then
    return text
  end
  return { text = " " .. best_code .. " ", highlight = highlights.GIT_MODIFIED }
end

return vim.tbl_deep_extend("force", common, M)
