local M = {}

-- In-memory state (session-only, not persisted)
local state = {
  find_files = { query = nil, selection_index = nil },
  live_grep = { query = nil, selection_index = nil },
}

-- Save search state for a picker (session only)
function M.save_search(picker_name, query, selection_index)
  if not query or query == "" then
    return
  end
  
  if state[picker_name] then
    state[picker_name].query = query
    state[picker_name].selection_index = selection_index
  end
end

-- Load search state for a picker
function M.load_search(picker_name)
  if state[picker_name] then
    return state[picker_name].query, state[picker_name].selection_index
  end
  return nil, nil
end

-- Clear search state for a picker
function M.clear_search(picker_name)
  if state[picker_name] then
    state[picker_name].query = nil
    state[picker_name].selection_index = nil
  end
end

-- Clear all state
function M.clear_all()
  for picker_name, _ in pairs(state) do
    state[picker_name].query = nil
    state[picker_name].selection_index = nil
  end
end

return M
