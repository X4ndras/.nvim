local M = {}
local MAX_UNDO_STACK = 10

M.clipboard = {
    files = {},
    action = nil
}

M.undo_stack = {}


local uv = vim.loop

-- Function to get the current directory
local function get_current_directory()
    if vim.bo.filetype == 'netrw' then
        return vim.b.netrw_curdir
    else
        return vim.fn.expand('%:p:h')
    end
end

---@class Actions
local Action = {
    rename          = 'rename',
    move            = 'move',
    copy            = 'copy',
    paste           = 'paste',

    delete_file     = 'delete_file',
    delete_dir      = 'delete_dir',

    create_file     = 'create_file',
    create_dir      = 'create_dir'
}

--- Define the UndoAction type
---@class UndoAction
---@field action    string
---@field path      string
---@field old_path  string  | nil
---@field is_dir    boolean | nil
---@field content   string  | table | nil 

---@param action UndoAction
local function push_undo_stack(action)
    table.insert(M.undo_stack, action)
    if #M.undo_stack > MAX_UNDO_STACK then
        table.remove(M.undo_stack, 1)
    end
end

-- Function to refresh netrw
local function refresh_netrw()
    local current_win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(current_win)

    -- Store original buffer for reference
    local original_buf = vim.api.nvim_win_get_buf(current_win)

    if vim.bo.filetype == 'netrw' then
        --vim.cmd('silent! normal j')
        vim.cmd('silent! e .')
        vim.cmd('redraw')
    end

    -- attempt cursor restoration if:
    if vim.api.nvim_win_is_valid(current_win) then
        local current_buf = vim.api.nvim_win_get_buf(current_win)

        if current_buf == original_buf then
            local line_count = vim.api.nvim_buf_line_count(current_buf)

            -- Adjust for 1-based vs 0-based indexing
            local max_row = math.max(line_count - 1, 0)
            local target_row = math.min(cursor[1] - 1, max_row)
            local target_col = math.min(cursor[2], vim.fn.col({target_row + 1, '$'}) - 1)

            pcall(vim.api.nvim_win_set_cursor, current_win, {
                target_row + 1,  -- Convert back to 1-based row
                target_col
            })
        end
    end
end

-- Function to open a file
function M.open_file()
    local dir = get_current_directory()
    local filename = vim.fn.expand('<cfile>')
    if filename == '' then
        vim.notify('No file selected', vim.log.levels.ERROR)
        return
    end
    local filepath = uv.fs_realpath(dir .. '/' .. filename)
    if not filepath then
        vim.notify('File not found: ' .. filename, vim.log.levels.ERROR)
        return
    end
    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
end

-- Function to rename a file
function M.rename_file()
    local dir = get_current_directory()
    local oldname = vim.fn.expand('<cfile>')
    if oldname == '' then
        vim.notify('No file selected', vim.log.levels.ERROR)
        return
    end
    local oldpath = vim.fn.resolve(dir .. '/' .. oldname)
    if not oldpath then
        vim.notify('File not found: ' .. oldname, vim.log.levels.ERROR)
        return
    end

    -- Prompt the user for the new name
    vim.ui.input({ prompt = 'New name: ', default = oldname }, function(newname)
        if not newname or newname == '' then
            vim.notify('Rename cancelled', vim.log.levels.INFO)
            return
        end
        local newpath = dir .. '/' .. newname

        local success, err = uv.fs_rename(oldpath, newpath)
        if not success then
            vim.notify('Rename failed: ' .. err, vim.log.levels.ERROR)
        else
            push_undo_stack({
                action = Action.rename,
                path = newpath,
                old_path = oldpath,
            })
            vim.notify('File renamed to ' .. newname)
            refresh_netrw()
        end
    end)

end

-- Function to cut a file
function M.cut_file()
    local dir = get_current_directory()
    local filename = vim.fn.expand('<cfile>')
    if filename == '' then
        vim.notify('No file selected', vim.log.levels.ERROR)
        return
    end
    local filepath = vim.fn.resolve(dir .. '/' .. filename)
    --local filepath = uv.fs_realpath(dir .. '/' .. filename)
    if not filepath then
        vim.notify('File not found: ' .. filename, vim.log.levels.ERROR)
        return
    end
    M.clipboard.files = { filepath }
    M.clipboard.action = 'cut'
    vim.notify('File cut: ' .. filepath)
end

-- Function to copy a file
function M.copy_file()
    local dir = get_current_directory()
    local filename = vim.fn.expand('<cfile>')
    if filename == '' then
        vim.notify('No file selected', vim.log.levels.ERROR)
        return
    end
    local filepath = uv.fs_realpath(dir .. '/' .. filename)
    if not filepath then
        vim.notify('File not found: ' .. filename, vim.log.levels.ERROR)
        return
    end

    M.clipboard.files = { filepath }
    M.clipboard.action = 'copy'
    vim.notify('File copied: ' .. filepath)
end

-- Function to paste a file
function M.paste_file()
    if not M.clipboard.action or #M.clipboard.files == 0 then
        vim.notify('Clipboard is empty', vim.log.levels.ERROR)
        return
    end

    local dir = get_current_directory()
    if dir == '' then
        vim.notify('No directory found', vim.log.levels.ERROR)
        return
    end

    for _, filepath in ipairs(M.clipboard.files) do
        -- Get the filename from the filepath
        local filename = vim.fn.fnamemodify(filepath, ':t')
        -- Construct the destination path
        local destpath = dir .. '/' .. filename

        if M.clipboard.action == 'cut' then
            -- Use uv to move the file
            local success, err = uv.fs_rename(filepath, destpath)
            if not success then
                vim.notify('Move failed: ' .. err, vim.log.levels.ERROR)
            else
                vim.notify('File moved to ' .. destpath)

                push_undo_stack({
                    action = Action.move,
                    path = destpath,
                    old_path = filepath,
                })
            end
        elseif M.clipboard.action == 'copy' then
            -- Check if destination exists
            local exists = uv.fs_stat(destpath) ~= nil

            -- Interactive prompt for conflicts
            if exists then
                local choice = vim.fn.input(string.format(
                    "'%s' exists. [R]ename, [O]verwrite, [C]ancel? ",
                    filename
                ), "")

                choice = choice:lower()
                if choice == "r" then
                    local newname = vim.fn.input("New name: ", filename)
                    if not newname or newname == "" then return end
                    destpath = dir .. '/' .. newname
                elseif choice == "o" then
                    uv.fs_unlink(destpath)  -- Remove existing file
                else
                    vim.notify("Paste cancelled", vim.log.levels.INFO)
                    return
                end
            end

            local success, err = uv.fs_copyfile(filepath, destpath)
            if not success then
                vim.notify('Copy failed: ' .. err, vim.log.levels.ERROR)
            else
                vim.notify('File copied to ' .. destpath)

                push_undo_stack({
                    action = Action.copy,
                    path = destpath,
                })
            end
        else
            vim.notify('Unknown clipboard action', vim.log.levels.ERROR)
        end
    end

    -- Clear the clipboard after pasting
    M.clipboard.files = {}
    M.clipboard.action = nil
    refresh_netrw()
end

--- Function to delete a file
local function delete_file()
    local dir = get_current_directory()
    local filename = vim.fn.expand('<cfile>')
    if filename == '' then
        vim.notify('No file selected', vim.log.levels.ERROR)
        return
    end
    local filepath = uv.fs_realpath(dir .. '/' .. filename)
    if not filepath then
        vim.notify('File not found: ' .. filename, vim.log.levels.ERROR)
        return
    end

    local stat = uv.fs_stat(filepath)
    if not stat then
        vim.notify('Could not stat file: ' .. filename, vim.log.levels.ERROR)
        return
    end

    -- Prompt the user for confirmation
    vim.ui.input({ prompt = 'Are you sure you want to delete ' .. filename .. '? (y/n): ' }, function(input)
        if input ~= 'y' then
            vim.notify('Delete cancelled', vim.log.levels.INFO)
            return
        end

        local content = vim.fn.readfile(filepath)
        local success, err = uv.fs_unlink(filepath)
        if not success then
            vim.notify('Delete failed: ' .. err, vim.log.levels.ERROR)
        else
            push_undo_stack({
                action = Action.delete_file,
                path = filepath,
                content = content,
            })
            vim.notify('File deleted: ' .. filename)
            refresh_netrw()
        end
    end)
end

--- Function to create a new file
function M.create_file()
    local dir = get_current_directory()

    -- Prompt the user for the file name
    vim.ui.input({ prompt = 'Enter file name: ' }, function(filename)
        if not filename or filename == '' then
            vim.notify('File creation cancelled', vim.log.levels.INFO)
            return
        end
        local filepath = dir .. '/' .. filename

        -- Create the file with an empty content
        local fd, err = uv.fs_open(filepath, "w", 420)
        if not fd then
            vim.notify('Could not create file: ' .. err, vim.log.levels.ERROR)
            return
        end
        uv.fs_close(fd)
        push_undo_stack({
            action = Action.create_file,
            path = filepath,
        })
        vim.notify('File created: ' .. filename)
        refresh_netrw()
    end)
end

function M.create_dir()
    local dir = get_current_directory()

    -- Prompt the user for the directory name
    vim.ui.input({ prompt = 'Enter new directory name: ' }, function(name)
        if not name or name == '' then
            vim.notify('Directory creation cancelled', vim.log.levels.INFO)
            return
        end
        local path = dir .. '/' .. name

        -- Create the directory
        local success, err = uv.fs_mkdir(path, 493)
        if not success then
            vim.notify('Could not create directory: ' .. err, vim.log.levels.ERROR)
            return
        end
        push_undo_stack({
            action = Action.create_dir,
            path = path,
        })
        vim.notify('Directory created: ' .. name)
        refresh_netrw()
    end)
end

-- Function to recursively delete a directory
local function delete_dir_recursive(path)
    local handle = uv.fs_scandir(path)
    if not handle then
        return false, 'Cannot read directory: ' .. path
    end

    while true do
        local name, rtype = uv.fs_scandir_next(handle)
        if not name then
            break
        end

        local new_path = path .. '/' .. name
        if rtype == 'directory' then
            local success, err = delete_dir_recursive(new_path)
            if not success then
                return false, err
            end
            uv.fs_rmdir(new_path)
        else
            uv.fs_unlink(new_path)
        end
    end

    return true
end

-- Function to delete a directory
local function delete_directory()
    local dir = get_current_directory()
    local dirname = vim.fn.expand('<cfile>')
    if dirname == '' then
        vim.notify('No directory selected', vim.log.levels.ERROR)
        return
    end
    local dirpath = uv.fs_realpath(dir .. '/' .. dirname)
    if not dirpath then
        vim.notify('Directory not found: ' .. dirname, vim.log.levels.ERROR)
        return
    end

    local content = {}

    -- Function to capture directory content before deletion
    local function capture_dir_content(path)
        local handle = uv.fs_scandir(path)
        if not handle then
            return false, 'Cannot read directory: ' .. path
        end

        local data = {}
        while true do
            local name, rtype = uv.fs_scandir_next(handle)
            if not name then
                break
            end

            local new_path = path .. '/' .. name
            if rtype == 'directory' then
                local subdir_data, err = capture_dir_content(new_path)
                if not subdir_data then
                    return false, err
                end
                data[name] = { type = rtype, content = subdir_data }
            else
                local fd, _ = uv.fs_open(new_path, "r", 438)
                if not fd then
                    return false, 'Cannot open file: ' .. new_path
                end
                local stat, _ = uv.fs_fstat(fd)
                if not stat then
                    uv.fs_close(fd)
                    return false, 'Cannot stat file: ' .. new_path
                end
                local content, _ = uv.fs_read(fd, stat.size, 0)
                uv.fs_close(fd)
                if not content then
                    return false, 'Cannot read file: ' .. new_path
                end
                data[name] = { type = rtype, content = content }
            end
        end

        return data
    end

    local capture_success, err = capture_dir_content(dirpath)
    if not capture_success then
        vim.notify('Could not capture directory content: ' .. err, vim.log.levels.ERROR)
        return
    end
    content = capture_success

    -- Prompt the user for confirmation
    vim.ui.input({
        prompt = 'Are you sure you want to delete directory ' .. dirname .. ' and all its contents? (y/n): '
    },
    function(input)
        if input ~= 'y' then
            vim.notify('Delete cancelled', vim.log.levels.INFO)
            return
        end

        local success, err = delete_dir_recursive(dirpath)
        if not success then
            vim.notify('Delete failed: ' .. err, vim.log.levels.ERROR)
        else
            push_undo_stack({
                action = Action.delete_dir,
                path = dirpath,
                content = content,
                is_dir = true
            })
            success, err = uv.fs_rmdir(dirpath)
            if not success then
                vim.notify('Could not remove directory: ' .. err, vim.log.levels.ERROR)
            else
                vim.notify('Directory deleted: ' .. dirname)
                refresh_netrw()
            end
        end
    end)
end

-- Function to delete a path (either a file or a directory)
function M.delete_path()
    local dir = get_current_directory()
    local name = vim.fn.expand('<cfile>')
    if name == '' then
        vim.notify('No file or directory selected', vim.log.levels.ERROR)
        return
    end
    local path = uv.fs_realpath(dir .. '/' .. name)
    if not path then
        vim.notify('File or directory not found: ' .. name, vim.log.levels.ERROR)
        return
    end

    local stat = uv.fs_stat(path)
    if stat and stat.type == "directory" then
        delete_directory()
    elseif stat and stat.type == "file" then
        delete_file()
    else
        vim.notify('Unknown type at path: ' .. name, vim.log.levels.ERROR)
    end
end

-- Function to restore a deleted directory
local function restore_dir(dirpath, content)
    local success, err = uv.fs_mkdir(dirpath, 493)
    if not success and err ~= "EEXIST" then
        return false, 'Could not restore directory: ' .. err
    end

    for name, info in pairs(content) do
        local new_path = dirpath .. '/' .. name
        if info.type == 'directory' then
            local success, err = restore_dir(new_path, info.content)
            if not success then
                return false, err
            end
        else
            local fd, err = uv.fs_open(new_path, "w", 420)
            if not fd then
                return false, 'Could not restore file: ' .. err
            end
            uv.fs_write(fd, info.content, -1)
            uv.fs_close(fd)
        end
    end

    return true
end

---@param action UndoAction
---@return boolean | nil
function M.restore_rename(action)
    local success, err = uv.fs_rename(action.path, action.old_path)
    if not success then
        vim.notify('Undo rename failed: ' .. err, vim.log.levels.ERROR)
        return false
    else
        vim.notify('Undo rename successful')
    end
end


---@param action UndoAction
---@return boolean | nil
function M.restore_delete(action)
    if action.is_dir then
        local success, err = restore_dir(action.path, action.content)
        if not success then
            vim.notify('Undo delete directory failed: ' .. err, vim.log.levels.ERROR)
        else
            vim.notify('Undo delete directory successful: Directory restored')
        end
    else
        local fd, err = uv.fs_open(action.path, "w", 420)
        if not fd then
            vim.notify('Undo delete failed: Could not recreate deleted file: ' .. err, vim.log.levels.ERROR)
            return false
        end
        uv.fs_write(fd, action.content, -1)
        uv.fs_close(fd)
        vim.notify('Undo delete successful: File restored')
    end
end

---@param action UndoAction
---@return boolean | nil
function M.restore_create_dir(action)
    local success, err = uv.fs_rmdir(action.path)
    if not success then
        vim.notify('Undo create directory failed: ' .. err, vim.log.levels.ERROR)
    else
        vim.notify('Undo create directory successful: Created directory deleted')
    end
end

---@param action UndoAction
---@return boolean | nil
function M.restore_create_file(action)
    local success, err = uv.fs_unlink(action.path)
    if not success then
        vim.notify('Undo create file failed: ' .. err, vim.log.levels.ERROR)
        return false
    else
        vim.notify('Undo create file successful: Created file deleted')
    end
end


local undo_functions = {
    [Action.rename]         = M.restore_rename,
    [Action.move]           = M.restore_rename,

    [Action.delete_file]    = M.restore_delete,
    [Action.delete_dir]     = M.restore_delete,
    [Action.create_file]    = M.restore_create_file,
    [Action.create_dir]     = M.restore_create_dir,
    [Action.copy]           = M.restore_create_file,
}

function M.undo()
    if #M.undo_stack == 0 then
        vim.notify('Nothing to undo', vim.log.levels.INFO)
        return
    end

    local last_action = table.remove(M.undo_stack)
    local undo_func = undo_functions[last_action.action]
    if undo_func then
        undo_func(last_action)
    else
        vim.notify('Unknown action, cannot undo', vim.log.levels.ERROR)
    end

    refresh_netrw()
end

return M
