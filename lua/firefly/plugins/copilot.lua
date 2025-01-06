-- code_llama.lua
local M = {}

-- Create a unique namespace for our virtual text and extmarks
local ns_id = vim.api.nvim_create_namespace('code_llama_completion')

local uv = vim.loop

-- Table to store the state
M.state = {
  bufnr = nil,
  ns_id = ns_id,
  full_completion = '',
  extmark_id = nil,
  handle = nil,
  completion_active = false,
}

function M.complete()
  if M.state.completion_active then
    print("A completion is already in progress.")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  M.state.bufnr = bufnr -- Store buffer number in state

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1] - 1 -- 0-based indexing
  --local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Determine the range of lines to include around the cursor
  local context_before = 40
  --local context_after = 2

  local start_line = math.max(0, current_line - context_before)
  --local end_line = math.min(total_lines, current_line + context_after)

  -- Fetch the lines from the buffer within the determined range
  --local context_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  --local context = table.concat(context_lines, "\n")

  local task = table.concat(vim.api.nvim_buf_get_lines(bufnr, start_line, cursor[1], false), "\n")

  -- Include the file type and the system prompt in the prompt sent to the model
  -- Compose the final prompt including file type and context
  local prompt = string.format(
    "- Respond only with the code completion.\n- Do not include any prefixes, suffixes, notes, quotes or Markdown\nFile type: %s\nYour task: %s",
    vim.bo.filetype,
    -- context,
    task
  )

  -- Prepare the payload for the API request
  local payload = {
    model = "codellama:7b",
    prompt = prompt,
    stream = true,
    temperature = 0.2,
    top_p = 0.9,
    max_tokens = 150,
    -- You can include stop tokens if supported
    -- stop = { "# End of code", "\n\n" },
  }

  print("Starting code completion for file type: " .. vim.bo.filetype)
  M.state.completion_active = true

  -- Reset the full_completion and extmark_id
  M.state.full_completion = ''
  M.state.extmark_id = nil

  -- Prepare the command and arguments
  local cmd = 'curl'
  local args = {
    '-N', '-s',
    'http://127.0.0.1:11434/api/generate',
    '--data', vim.fn.json_encode(payload)
  }

  -- Set up handles for stdout and stderr
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  -- Spawn the process
  local handle
  handle = uv.spawn(cmd, {
      args = args,
      stdio = { nil, stdout, stderr },
    },
    function(code, _)
      stdout:close()
      stderr:close()
      handle:close()
      M.state.completion_active = false
      M.state.handle = nil
      print('Code completion finished with exit code', code)
    end)

  -- Store the handle in state
  M.state.handle = handle

  -- Read data from stdout
  uv.read_start(stdout, function(err, data)
    if err then
      print('Error:', err)
      return
    end

    if not M.state.completion_active then
      -- Completion has been cancelled, ignore any further data
      return
    end

    if data and type(data) == 'string' then
      -- Split the data into lines
      for line_data in data:gmatch("[^\r\n]+") do
        if line_data ~= '' then
          -- Print received line for debugging
          -- print('Received line: ' .. line_data)

          -- Attempt to parse the JSON response using vim.json.decode
          local ok, parsed_response = pcall(vim.json.decode, line_data)
          if ok and parsed_response and parsed_response.response then
            -- Append the latest chunk to the full completion
            M.state.full_completion = M.state.full_completion .. parsed_response.response

            -- Schedule the UI updates on the main thread
            vim.schedule(function()
              if not M.state.completion_active then
                -- Completion has been cancelled, do not update UI
                return
              end

              -- Clear the previous virtual lines
              if M.state.extmark_id then
                vim.api.nvim_buf_del_extmark(bufnr, ns_id, M.state.extmark_id)
              end

              -- Split the completion into lines
              local completion_lines = {}
              for s in M.state.full_completion:gmatch("[^\r\n]+") do
                table.insert(completion_lines, { { s, 'Comment' } })
              end

              -- Set the virtual lines below the current line
              M.state.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, current_line, 0, {
                virt_lines = completion_lines,
                virt_lines_above = false,
              })
            end)
          else
            -- Print an error message if JSON parsing fails
            print('Error parsing JSON.')
            if not ok then
              print('Parsing error: ' .. parsed_response)
            end
          end
        end
      end
    else
      print('Received non-string data')
    end
  end)

  -- Read data from stderr
  uv.read_start(stderr, function(err, data)
    if err then
      print('Error:', err)
      return
    end

    if not M.state.completion_active then
      -- Completion has been cancelled, ignore any further data
      return
    end

    if data and type(data) == 'string' then
      -- Handle any errors from the curl command
      for line in data:gmatch("[^\r\n]+") do
        if line ~= '' then
          print('Error: ' .. line)
        end
      end
    end
  end)
end

function M.accept_completion()
  if not M.state.full_completion or M.state.full_completion == '' then
    print("No completion to accept.")
    return
  end

  -- Cancel any ongoing completion
  M.cancel_completion()

  local bufnr = M.state.bufnr
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    print("Buffer is not valid.")
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1] -- 1-based indexing

  -- Insert the completion lines below the current line
  local lines = {}
  for s in M.state.full_completion:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  vim.api.nvim_buf_set_lines(bufnr, current_line, current_line, false, lines)

  -- Remove the virtual lines
  M.clear_completion()
end

function M.discard_completion()
  M.cancel_completion()
  M.clear_completion()
  print("Completion discarded.")
end

function M.cancel_completion()
  if M.state.handle and M.state.completion_active then
    -- Terminate the process
    local success, err = pcall(function()
      uv.process_kill(M.state.handle, 'sigterm')
    end)
    if not success then
      print('Error terminating process:', err)
    end
    M.state.handle = nil
  end
  M.state.completion_active = false
end

function M.clear_completion()
  local bufnr = M.state.bufnr
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) and M.state.extmark_id then
    vim.api.nvim_buf_del_extmark(bufnr, M.state.ns_id, M.state.extmark_id)
    M.state.extmark_id = nil
  end
  M.state.full_completion = ''
end

return M
