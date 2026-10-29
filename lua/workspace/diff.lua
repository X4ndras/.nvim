-- Diffview-style view of the changes of every repository in every workspace.
--
-- Left: a file panel grouped as workspace → repository → Changes / Staged
-- changes / Conflicts. Right: a side-by-side diff of the selected file (index
-- vs working tree for changes, HEAD vs index for staged changes). The right
-- side of a working-tree diff is the real file, so it can be edited.
--
-- Keys (as in Diffview's file panel):
--   <cr> o l   open file / toggle fold     h  close fold    za  toggle fold
--   <tab>      next file  <s-tab> previous file (also in the diff windows)
--   - s        stage / unstage (file, section or repository)
--   S / U      stage all / unstage all of the repository
--   X          discard the changes of the file (asks first)
--   gf         open the file in the previous tab
--   R          refresh        q  close

local store = require("workspace.store")
local repos = require("workspace.repos")

local api = vim.api
local uv = vim.uv

local M = {}

M.config = {
  width = 40,
}

local ns = api.nvim_create_namespace("workspace_diff")
local view -- the open view, see M.open()

-- Highlights -------------------------------------------------------------------

local function set_highlights()
  local links = {
    WorkspaceDiffWorkspace = "DiffviewFilePanelTitle",
    WorkspaceDiffRepo = "Title",
    WorkspaceDiffSection = "Statement",
    WorkspaceDiffCounter = "Number",
    WorkspaceDiffBranch = "Comment",
    WorkspaceDiffPath = "Comment",
    WorkspaceDiffFold = "Comment",
    WorkspaceDiffClean = "Comment",
    WorkspaceDiffSelected = "Visual",
    WorkspaceDiffSync = "DiagnosticWarn",
  }
  for group, target in pairs(links) do
    api.nvim_set_hl(0, group, { link = target, default = true })
  end
end

local status_hl = {
  M = "DiffviewStatusModified",
  T = "DiffviewStatusTypeChanged",
  A = "DiffviewStatusAdded",
  D = "DiffviewStatusDeleted",
  R = "DiffviewStatusRenamed",
  C = "DiffviewStatusCopied",
  U = "DiffviewStatusUnmerged",
  ["?"] = "DiffviewStatusUntracked",
}

-- Git ----------------------------------------------------------------------------

local conflict_codes = { DD = true, AU = true, UD = true, UA = true, DU = true, AA = true, UU = true }

--- Parse `git status --porcelain=v1 -b -z` into staged / unstaged / conflict entries.
local function parse(out)
  local st = { branch = "?", ahead = 0, behind = 0, staged = {}, unstaged = {}, conflicts = {} }
  local fields = vim.split(out, "\0", { plain = true })
  local i = 1
  while i <= #fields do
    local f = fields[i]
    if f:sub(1, 3) == "## " then
      local head = f:sub(4)
      local branch = head:match("^No commits yet on (.+)$")
        or head:match("^Initial commit on (.+)$")
        or head:match("^(.-)%.%.%.")
        or head:match("^(%S+)")
      st.branch = branch == "HEAD" and "detached" or branch
      st.ahead = tonumber(head:match("ahead (%d+)")) or 0
      st.behind = tonumber(head:match("behind (%d+)")) or 0
    elseif #f > 3 then
      local xy, rel = f:sub(1, 2), f:sub(4)
      local orig
      if xy:find("[RC]") then
        i = i + 1
        orig = fields[i]
      end
      local x, y = xy:sub(1, 1), xy:sub(2, 2)
      if conflict_codes[xy] then
        table.insert(st.conflicts, { kind = "conflicts", status = "U", rel = rel })
      elseif xy == "??" then
        table.insert(st.unstaged, { kind = "unstaged", status = "?", rel = rel })
      elseif xy ~= "!!" then
        if x ~= " " then
          table.insert(st.staged, { kind = "staged", status = x, rel = rel, orig = orig })
        end
        if y ~= " " then
          table.insert(st.unstaged, { kind = "unstaged", status = y, rel = rel })
        end
      end
    end
    i = i + 1
  end
  for _, list in ipairs({ st.staged, st.unstaged, st.conflicts }) do
    table.sort(list, function(a, b)
      return a.rel < b.rel
    end)
  end
  st.count = #st.staged + #st.unstaged + #st.conflicts
  return st
end

local function git(root, args)
  local obj = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = true }):wait()
  if obj.code ~= 0 then
    vim.notify(vim.trim(obj.stderr or "git failed"), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function has_head(root)
  return vim.system({ "git", "-C", root, "rev-parse", "--verify", "-q", "HEAD" }):wait().code == 0
end

--- Lines of `git show <spec>`, or nil if it doesn't exist there.
local function show(root, spec)
  local obj = vim.system({ "git", "-C", root, "show", spec }, { text = true }):wait()
  if obj.code ~= 0 then
    return nil
  end
  local out = obj.stdout or ""
  if out:find("\0", 1, true) then
    return { "(binary file)" }
  end
  local lines = vim.split(out, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

-- Collecting ----------------------------------------------------------------------

local function repo_label(root, project)
  if root == project or vim.startswith(root, project .. "/") then
    return vim.fs.relpath(vim.fs.dirname(project), root) or vim.fs.basename(root)
  end
  return vim.fs.basename(root)
end

--- Every workspace with its repositories and their status. The current
--- workspace comes first. Calls `callback(model)` when all statuses are in.
local function collect(callback)
  local current = require("workspace").current()
  local names = store.list()
  table.sort(names, function(a, b)
    if current and (a == current.name) ~= (b == current.name) then
      return a == current.name
    end
    return a:lower() < b:lower()
  end)

  local model, roots = {}, {}
  for _, name in ipairs(names) do
    local ws = store.load(name)
    if ws then
      local group, seen = { name = name, repos = {} }, {}
      for _, project in ipairs(store.projects(ws)) do
        if uv.fs_stat(project) then
          for _, root in ipairs(repos.for_project(project)) do
            if not seen[root] then
              seen[root] = true
              table.insert(group.repos, { root = root, label = repo_label(root, project) })
              roots[root] = true
            end
          end
        end
      end
      table.insert(model, group)
    end
  end

  local pending, results = 0, {}
  local function done()
    for _, group in ipairs(model) do
      for _, r in ipairs(group.repos) do
        r.status = results[r.root]
      end
    end
    callback(model)
  end
  for root in pairs(roots) do
    pending = pending + 1
    -- --no-optional-locks: don't take index.lock, so a `git add` from the
    -- panel can't collide with a status that's still running.
    vim.system(
      { "git", "--no-optional-locks", "-C", root, "status", "--porcelain=v1", "-b", "-z", "--untracked-files=all" },
      { text = true },
      function(obj)
        vim.schedule(function()
          results[root] = obj.code == 0 and parse(obj.stdout or "") or { error = vim.trim(obj.stderr or "") }
          pending = pending - 1
          if pending == 0 then
            done()
          end
        end)
      end
    )
  end
  if pending == 0 then
    done()
  end
end

-- Panel ------------------------------------------------------------------------------

local sections = {
  { kind = "conflicts", title = "Conflicts" },
  { kind = "unstaged", title = "Changes" },
  { kind = "staged", title = "Staged changes" },
}

local function entry_key(root, e)
  return root .. "\0" .. e.kind .. "\0" .. e.rel
end

local function file_icon(rel)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "", nil
  end
  local name = vim.fs.basename(rel)
  local icon, hl = devicons.get_icon(name, name:match("%.([^.]+)$"), { default = true })
  return icon or "", hl
end

--- Draw the panel. Lines are built from segments of { text, highlight }.
local function render()
  if not (view and api.nvim_buf_is_valid(view.panel_buf)) then
    return
  end
  local lines, marks, items = {}, {}, {}
  local collapsed = view.collapsed

  local function line(segments, item)
    local text, col = "", 0
    for _, seg in ipairs(segments) do
      local s = seg[1]
      if seg[2] then
        table.insert(marks, { #lines, col, col + #s, seg[2] })
      end
      text = text .. s
      col = col + #s
    end
    table.insert(lines, text)
    items[#lines] = item
  end
  local function fold(key)
    return collapsed[key] and " " or " "
  end

  view.files = {} -- every visible-or-not file in display order, for <tab>

  if not view.model then
    line({ { " Loading changes…", "WorkspaceDiffClean" } })
  elseif #view.model == 0 then
    line({ { " No workspaces yet", "WorkspaceDiffClean" } })
  end

  for _, group in ipairs(view.model or {}) do
    local total, changed = 0, {}
    for _, r in ipairs(group.repos) do
      if r.status and (r.status.error or (r.status.count or 0) > 0) then
        total = total + (r.status.count or 0)
        table.insert(changed, r)
      end
    end
    local wkey = "ws:" .. group.name
    line({
      { fold(wkey), "WorkspaceDiffFold" },
      { group.name, "WorkspaceDiffWorkspace" },
      { total > 0 and ("  " .. total) or "  ✓", total > 0 and "WorkspaceDiffCounter" or "WorkspaceDiffClean" },
    }, { type = "fold", key = wkey })

    if not collapsed[wkey] then
      if #changed == 0 then
        line({ { "    no changes", "WorkspaceDiffClean" } })
      end
      for _, r in ipairs(changed) do
        local st = r.status
        local rkey = "repo:" .. group.name .. ":" .. r.root
        local segs = {
          { "  " .. fold(rkey), "WorkspaceDiffFold" },
          { r.label, "WorkspaceDiffRepo" },
        }
        if st.error then
          table.insert(segs, { "  git error", "DiagnosticError" })
        else
          table.insert(segs, { "  " .. st.branch, "WorkspaceDiffBranch" })
          if st.ahead > 0 then
            table.insert(segs, { " ↑" .. st.ahead, "WorkspaceDiffSync" })
          end
          if st.behind > 0 then
            table.insert(segs, { " ↓" .. st.behind, "WorkspaceDiffSync" })
          end
          table.insert(segs, { "  " .. st.count, "WorkspaceDiffCounter" })
        end
        line(segs, { type = "repo", key = rkey, root = r.root, status = st })

        if not collapsed[rkey] and not st.error then
          for _, sec in ipairs(sections) do
            local list = st[sec.kind]
            if #list > 0 then
              local skey = "sec:" .. group.name .. ":" .. r.root .. ":" .. sec.kind
              line({
                { "    " .. fold(skey), "WorkspaceDiffFold" },
                { sec.title, "WorkspaceDiffSection" },
                { " (" .. #list .. ")", "WorkspaceDiffCounter" },
              }, { type = "section", key = skey, root = r.root, kind = sec.kind, list = list })
              for _, e in ipairs(list) do
                local item = { type = "file", root = r.root, status = st, entry = e, key = entry_key(r.root, e) }
                table.insert(view.files, item)
                if not collapsed[skey] then
                  local icon, icon_hl = file_icon(e.rel)
                  local dir = vim.fs.dirname(e.rel)
                  local segs2 = {
                    { "        " .. e.status .. " ", status_hl[e.status] or "DiffviewStatusUnknown" },
                    { icon .. " ", icon_hl },
                    { vim.fs.basename(e.rel), nil },
                  }
                  if dir ~= "." then
                    table.insert(segs2, { " " .. dir, "WorkspaceDiffPath" })
                  end
                  if e.orig then
                    table.insert(segs2, { " ← " .. e.orig, "WorkspaceDiffPath" })
                  end
                  line(segs2, item)
                  item.lnum = #lines
                end
              end
            end
          end
        end
      end
    end
  end

  local buf = view.panel_buf
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
  for lnum, item in pairs(items) do
    if item.type == "file" and item.key == view.selected then
      api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, { line_hl_group = "WorkspaceDiffSelected" })
    end
  end
  view.items = items
end

-- Diff windows ---------------------------------------------------------------------

local function scratch(name, lines, filetype)
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  -- The old buffer of the same name may still be shown until it's replaced.
  local old = vim.fn.bufnr("^wsdiff://" .. vim.fn.escape(name, "\\/.*$^~[]") .. "$")
  if old > 0 and old ~= buf then
    pcall(api.nvim_buf_set_name, old, "")
  end
  pcall(api.nvim_buf_set_name, buf, "wsdiff://" .. name)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines or {})
  vim.bo[buf].modifiable = false
  if filetype then
    vim.bo[buf].filetype = filetype
  end
  return buf
end

local nav_keys = { "<tab>", "<s-tab>" }

local function map_nav(buf)
  if view.mapped[buf] then
    return
  end
  view.mapped[buf] = true
  vim.keymap.set("n", "<tab>", function() M.select_relative(1) end, { buffer = buf, desc = "Next changed file" })
  vim.keymap.set("n", "<s-tab>", function() M.select_relative(-1) end, { buffer = buf, desc = "Previous changed file" })
end

local function unmap_nav()
  for buf in pairs(view.mapped) do
    if api.nvim_buf_is_valid(buf) and buf ~= view.panel_buf then
      for _, key in ipairs(nav_keys) do
        pcall(vim.keymap.del, "n", key, { buffer = buf })
      end
    end
  end
  view.mapped = { [view.panel_buf] = view.mapped[view.panel_buf] }
end

--- Make sure the two diff windows exist next to the panel.
local function ensure_layout()
  local valid = api.nvim_win_is_valid
  if view.left and valid(view.left) and view.right and valid(view.right) then
    return
  end
  api.nvim_set_current_tabpage(view.tab)
  for _, win in ipairs({ view.left, view.right }) do
    if win and valid(win) then
      pcall(api.nvim_win_close, win, true)
    end
  end
  view.left = api.nvim_open_win(scratch("old", {}), false, { split = "right", win = view.panel_win })
  view.right = api.nvim_open_win(scratch("new", {}), false, { split = "right", win = view.left })
  api.nvim_win_set_width(view.panel_win, M.config.width)
end

local function set_win_buf(win, buf)
  api.nvim_win_call(win, function()
    vim.cmd("diffoff")
  end)
  api.nvim_win_set_buf(win, buf)
end

--- Whether `win` already shows the file at `path`.
local function shows_file(win, path)
  local name = api.nvim_buf_get_name(api.nvim_win_get_buf(win))
  if name == "" then
    return false
  end
  return (uv.fs_realpath(name) or name) == (uv.fs_realpath(path) or path)
end

--- Show the diff of a file entry. With `opts.refresh`, re-showing the file
--- that's already selected keeps the cursor, scroll and folds as they are.
local function open_entry(item, opts)
  local keep = opts and opts.refresh and item.key == view.selected
  ensure_layout()
  unmap_nav()
  local root, e = item.root, item.entry
  local abs = root .. "/" .. e.rel
  local ft = vim.filetype.match({ filename = abs })
  local tag = vim.fs.basename(root) .. "/" .. e.rel

  local left_lines, right_buf
  if vim.fn.isdirectory(abs) == 1 then
    -- A nested repository tracked by this one: compare the recorded commit
    -- with the one checked out, like `git diff` does.
    local function line_of(cmd)
      local obj = vim.system(cmd, { text = true }):wait()
      return obj.code == 0 and vim.trim(obj.stdout) or ""
    end
    local recorded = line_of({ "git", "-C", root, "ls-files", "-s", "--", e.rel }):match("^%d+ (%x+)") or "?"
    local head = line_of({ "git", "-C", abs, "rev-parse", "HEAD" })
    local dirty = line_of({ "git", "-C", abs, "status", "--porcelain" }) ~= "" and "-dirty" or ""
    set_win_buf(view.left, scratch("RECORDED/" .. tag, { "Subproject commit " .. recorded }))
    set_win_buf(view.right, scratch("CHECKED-OUT/" .. tag, { "Subproject commit " .. head .. dirty }))
    for _, win in ipairs({ view.left, view.right }) do
      api.nvim_win_call(win, function()
        vim.cmd("diffthis")
      end)
    end
    view.selected = item.key
    render()
    return
  end

  if e.kind == "staged" then
    left_lines = (e.status ~= "A" and has_head(root)) and show(root, "HEAD:" .. (e.orig or e.rel)) or {}
    right_buf = scratch("INDEX/" .. tag, e.status ~= "D" and show(root, ":" .. e.rel) or {}, ft)
  elseif e.kind == "conflicts" then
    left_lines = show(root, ":2:" .. e.rel) or {}
  else
    left_lines = e.status ~= "?" and (show(root, ":" .. e.rel) or {}) or {}
    if e.status == "D" then
      right_buf = scratch("DELETED/" .. tag, {}, ft)
    end
  end

  local left_name = (e.kind == "staged" and "HEAD/" or e.kind == "conflicts" and "OURS/" or "INDEX/") .. tag
  local right_view = keep and api.nvim_win_call(view.right, vim.fn.winsaveview)
  local left_buf = scratch(left_name, left_lines, ft)
  set_win_buf(view.left, left_buf)

  -- The real file is left alone when it's already shown: no :edit (which
  -- fails on unsaved changes) and no diffoff/diffthis (which reset folds).
  local right_kept = false
  if right_buf then
    set_win_buf(view.right, right_buf)
  elseif shows_file(view.right, abs) then
    right_buf = api.nvim_win_get_buf(view.right)
    right_kept = true
  else
    api.nvim_win_call(view.right, function()
      vim.cmd("diffoff")
      vim.cmd("edit " .. vim.fn.fnameescape(abs))
    end)
    right_buf = api.nvim_win_get_buf(view.right)
  end

  map_nav(left_buf)
  map_nav(right_buf)
  local diff_wins = right_kept and { view.left } or { view.left, view.right }
  for _, win in ipairs(diff_wins) do
    api.nvim_win_call(win, function()
      vim.cmd("diffthis")
      if not keep then
        vim.wo.foldlevel = 0
      end
    end)
  end
  api.nvim_win_call(view.right, function()
    if keep then
      vim.cmd("diffupdate")
      vim.fn.winrestview(right_view)
    else
      pcall(vim.cmd, "normal! gg]c")
    end
  end)

  view.selected = item.key
  render()
end

local function item_at_cursor()
  local lnum = api.nvim_win_get_cursor(view.panel_win)[1]
  return view.items and view.items[lnum]
end

local function focus_selected_line()
  for lnum, item in pairs(view.items or {}) do
    if item.type == "file" and item.key == view.selected then
      pcall(api.nvim_win_set_cursor, view.panel_win, { lnum, 0 })
      return
    end
  end
end

--- Select the next (`step` = 1) or previous (-1) changed file.
function M.select_relative(step)
  if not view or #view.files == 0 then
    return
  end
  local idx = 0
  for i, item in ipairs(view.files) do
    if item.key == view.selected then
      idx = i
    end
  end
  idx = ((idx - 1 + step) % #view.files) + 1
  local item = view.files[idx]
  -- Unfold whatever hides the file.
  for k in pairs(view.collapsed) do
    if k:find(item.root, 1, true) and (k:match("^repo:") or k:match("^sec:")) then
      view.collapsed[k] = nil
    end
  end
  open_entry(item)
  focus_selected_line()
end

-- Actions --------------------------------------------------------------------------

local function refresh(keep_selection)
  if not view then
    return
  end
  -- Refreshes can overlap (e.g. staging several files quickly); only the
  -- newest one may update the view.
  view.generation = view.generation + 1
  local generation = view.generation
  collect(function(model)
    if not view or view.generation ~= generation then
      return
    end
    view.model = model
    render()
    -- Keep showing the same file if it still has changes, else the next one.
    local target
    for _, item in ipairs(view.files) do
      if item.key == view.selected then
        target = item
      end
    end
    if not target and keep_selection ~= false then
      target = view.files[math.min(view.selected_index or 1, #view.files)]
    end
    if target and api.nvim_tabpage_is_valid(view.tab) then
      local cur = api.nvim_get_current_win()
      open_entry(target, { refresh = true })
      if api.nvim_win_is_valid(cur) then
        api.nvim_set_current_win(cur)
      end
    end
  end)
end
M.refresh = refresh

local function remember_index()
  for i, item in ipairs(view.files) do
    if item.key == view.selected then
      view.selected_index = i
    end
  end
end

local function unstage(root, rels)
  if has_head(root) then
    return git(root, vim.list_extend({ "restore", "--staged", "--" }, rels))
  end
  return git(root, vim.list_extend({ "rm", "--cached", "-r", "-q", "--" }, rels))
end

local function rels(list)
  return vim.tbl_map(function(e)
    return e.rel
  end, list)
end

local function after_git()
  remember_index()
  refresh()
  pcall(function()
    require("neo-tree.events").fire_event(require("neo-tree.events").GIT_EVENT)
  end)
end

local function toggle_stage()
  local item = item_at_cursor()
  if not item then
    return
  end
  local ok
  if item.type == "file" then
    if item.entry.kind == "staged" then
      ok = unstage(item.root, { item.entry.rel })
    else
      ok = git(item.root, { "add", "-A", "--", item.entry.rel })
    end
  elseif item.type == "section" then
    if item.kind == "staged" then
      ok = unstage(item.root, rels(item.list))
    else
      ok = git(item.root, vim.list_extend({ "add", "-A", "--" }, rels(item.list)))
    end
  elseif item.type == "repo" then
    if #item.status.unstaged + #item.status.conflicts > 0 then
      ok = git(item.root, { "add", "-A" })
    else
      ok = unstage(item.root, { "." })
    end
  end
  if ok then
    after_git()
  end
end

local function repo_of_cursor()
  local item = item_at_cursor()
  return item and item.root
end

local function stage_all()
  local root = repo_of_cursor()
  if root and git(root, { "add", "-A" }) then
    after_git()
  end
end

local function unstage_all()
  local root = repo_of_cursor()
  if root and unstage(root, { "." }) then
    after_git()
  end
end

local function restore()
  local item = item_at_cursor()
  if not item or item.type ~= "file" then
    return
  end
  local e, root = item.entry, item.root
  local what, args
  if e.status == "?" then
    what = "Delete untracked file " .. e.rel .. "?"
    args = { "clean", "-f", "--", e.rel }
  elseif e.kind ~= "staged" then
    what = "Discard changes to " .. e.rel .. "?"
    args = { "restore", "--", e.rel }
  elseif e.status == "A" then
    what = "Delete new file " .. e.rel .. "?"
    args = { "rm", "-f", "-q", "--", e.rel }
  elseif e.status == "R" then
    -- Restore both paths: the old one comes back, the new one goes away.
    what = "Undo rename " .. e.orig .. " → " .. e.rel .. "? " .. e.rel .. " will be removed."
    args = { "restore", "--source=HEAD", "--staged", "--worktree", "--", e.orig, e.rel }
  else
    what = "Discard staged changes to " .. e.rel .. "?"
    args = { "restore", "--source=HEAD", "--staged", "--worktree", "--", e.rel }
  end
  -- Discarding a staged file also resets the working tree, so unstaged
  -- edits to it are lost as well. Say so.
  if e.kind == "staged" then
    for _, u in ipairs(item.status.unstaged) do
      if u.rel == e.rel then
        what = what .. "\nIts unstaged changes will be lost too."
        break
      end
    end
  end
  if vim.fn.confirm(what, "&Yes\n&No", 2) ~= 1 then
    return
  end
  if git(root, args) then
    vim.cmd("checktime")
    after_git()
  end
end

local function activate()
  local item = item_at_cursor()
  if not item then
    return
  end
  if item.type == "file" then
    open_entry(item)
  elseif item.key then
    view.collapsed[item.key] = not view.collapsed[item.key] or nil
    render()
  end
end

local function set_fold(state)
  local item = item_at_cursor()
  if not item then
    return
  end
  local key = item.key
  if item.type == "file" then
    -- Close the section the file is in.
    local lnum = api.nvim_win_get_cursor(view.panel_win)[1]
    for l = lnum, 1, -1 do
      local it = view.items[l]
      if it and it.type == "section" then
        key = it.key
        pcall(api.nvim_win_set_cursor, view.panel_win, { l, 0 })
        break
      end
    end
  end
  if state == "toggle" then
    view.collapsed[key] = not view.collapsed[key] or nil
  else
    view.collapsed[key] = state == "close" or nil
  end
  render()
end

local function goto_file()
  local item = item_at_cursor()
  if not item or item.type ~= "file" then
    return
  end
  local abs = item.root .. "/" .. item.entry.rel
  vim.cmd("tabprevious")
  if api.nvim_get_current_tabpage() == view.tab then
    vim.cmd("tabnew")
  end
  vim.cmd("edit " .. vim.fn.fnameescape(abs))
end

-- Open / close ---------------------------------------------------------------------

local function setup_panel(buf)
  local function map(keys, fn, desc)
    for _, key in ipairs(keys) do
      vim.keymap.set("n", key, fn, { buffer = buf, nowait = true, desc = desc })
    end
  end
  map({ "<cr>", "o", "l", "<2-LeftMouse>" }, activate, "Open file / toggle fold")
  map({ "-", "s" }, toggle_stage, "Stage / unstage")
  map({ "S" }, stage_all, "Stage all")
  map({ "U" }, unstage_all, "Unstage all")
  map({ "X" }, restore, "Discard changes")
  map({ "h", "zc" }, function() set_fold("close") end, "Close fold")
  map({ "zo" }, function() set_fold("open") end, "Open fold")
  map({ "za" }, function() set_fold("toggle") end, "Toggle fold")
  map({ "zR" }, function()
    view.collapsed = {}
    render()
  end, "Open all folds")
  map({ "R" }, function()
    repos.forget()
    refresh()
  end, "Refresh")
  map({ "gf" }, goto_file, "Open file")
  map({ "q" }, M.close, "Close")
  view.mapped[buf] = true
  vim.keymap.set("n", "<tab>", function() M.select_relative(1) end, { buffer = buf })
  vim.keymap.set("n", "<s-tab>", function() M.select_relative(-1) end, { buffer = buf })
end

function M.is_open()
  return view ~= nil and api.nvim_tabpage_is_valid(view.tab)
end

function M.open()
  if M.is_open() then
    api.nvim_set_current_tabpage(view.tab)
    return
  end
  set_highlights()
  vim.cmd("tabnew")
  local placeholder = api.nvim_get_current_buf()
  vim.bo[placeholder].bufhidden = "wipe"

  local panel_buf = api.nvim_create_buf(false, true)
  vim.bo[panel_buf].filetype = "WorkspaceDiff"
  vim.bo[panel_buf].bufhidden = "wipe"
  pcall(api.nvim_buf_set_name, panel_buf, "Workspace changes")
  local panel_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(panel_win, panel_buf)

  view = {
    tab = api.nvim_get_current_tabpage(),
    panel_buf = panel_buf,
    panel_win = panel_win,
    collapsed = {},
    mapped = {},
    files = {},
    generation = 0,
  }
  for opt, value in pairs({
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
    cursorline = true,
    wrap = false,
    spell = false,
    winfixwidth = true,
    colorcolumn = "",
  }) do
    vim.wo[panel_win][opt] = value
  end
  setup_panel(panel_buf)
  ensure_layout()
  api.nvim_set_current_win(panel_win)
  render()

  local generation = view.generation
  collect(function(model)
    if not view or view.generation ~= generation then
      return
    end
    view.model = model
    render()
    if view.files[1] then
      open_entry(view.files[1])
      api.nvim_set_current_win(view.panel_win)
      focus_selected_line()
    end
  end)
end

function M.close()
  if not view then
    return
  end
  local v = view
  unmap_nav()
  view = nil
  if api.nvim_tabpage_is_valid(v.tab) then
    if #api.nvim_list_tabpages() == 1 then
      vim.cmd("tabnew")
    end
    api.nvim_set_current_tabpage(v.tab)
    vim.cmd("tabclose")
  end
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

local group = api.nvim_create_augroup("workspace_diff", { clear = true })

api.nvim_create_autocmd("TabClosed", {
  group = group,
  callback = function()
    if view and not api.nvim_tabpage_is_valid(view.tab) then
      unmap_nav()
      view = nil
    end
  end,
})

local pending_refresh
api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
  group = group,
  callback = function(args)
    if not M.is_open() or (args.buf and vim.bo[args.buf].filetype == "WorkspaceDiff") then
      return
    end
    if pending_refresh then
      pending_refresh:stop()
    end
    pending_refresh = vim.defer_fn(function()
      pending_refresh = nil
      if M.is_open() then
        remember_index()
        refresh()
      end
    end, 200)
  end,
})

return M
