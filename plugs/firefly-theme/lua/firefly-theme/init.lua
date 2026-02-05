local firefly = {}
local theme = require("firefly-theme.theme")
local palette = require("firefly-theme.palette")

-- Configuration with defaults
firefly.config = {
    persist_theme = true,  -- Save and restore last used theme
    default_theme = nil,   -- Fallback theme if no saved theme exists (nil = use built-in defaults)
}

-- File path for persisting the last used theme
local function get_persistence_file()
    return vim.fn.stdpath("data") .. "/firefly-theme-last.txt"
end

-- Save the current theme name to file
local function save_theme(theme_name)
    if not firefly.config.persist_theme then return end

    local file = io.open(get_persistence_file(), "w")
    if file then
        file:write(theme_name)
        file:close()
    end
end

-- Load the saved theme name from file
local function load_saved_theme()
    if not firefly.config.persist_theme then return nil end

    local file = io.open(get_persistence_file(), "r")
    if file then
        local theme_name = file:read("*l")
        file:close()
        return theme_name
    end
    return nil
end

-- Setup function for user configuration
function firefly.setup(opts)
    firefly.config = vim.tbl_deep_extend("force", firefly.config, opts or {})
end

function firefly.colorize()
    -- read themes folder
    local themes_dir = vim.fn.stdpath("config") .. "/themes"

    -- Scan themes directory for JSON files
    local function read_json(path)
        local file = io.open(path, "r")
        if not file then
            return nil
        end
        local content = file:read("*all")
        file:close()
        local ok, decoded = pcall(vim.json.decode, content)
        if not ok then
            return nil
        end
        return decoded
    end

    local function is_theme_file(path)
        local data = read_json(path)
        if not data then
            return false
        end
        if data.colors or data.color0 or data.bg0 then
            return true
        end
        return false
    end

    local function scan_themes()
        local themes = {}
        local handle = vim.loop.fs_scandir(themes_dir)
        if handle then
            while true do
                local name, _ = vim.loop.fs_scandir_next(handle)
                if not name then break end

                if name:match("%.json$") then
                    local theme_path = string.format("%s/%s", themes_dir, name)
                    if is_theme_file(theme_path) then
                        local theme_name = name:gsub("%.json$", "")
                        table.insert(themes, theme_name)
                    end
                end
            end
        end
        return themes
    end

    local custom_themes = scan_themes()

    -- Internal function to load a custom theme by name
    local function load_custom_theme(theme_name, should_save)
        local theme_path = string.format("%s/%s.json", themes_dir, theme_name)
        local success = pcall(function()
            palette.read_theme(theme_path)
        end)
        if success then
            theme.load()
            vim.g.firefly_last_theme = theme_name
            if should_save then
                save_theme(theme_name)
            end
            return true
        else
            return false
        end
    end

    vim.api.nvim_create_user_command("Colorscheme", function(args)
        local theme_name = args.args

        if vim.tbl_contains(custom_themes, theme_name) then
            if not load_custom_theme(theme_name, true) then
                print("Error loading theme from json: " .. theme_name)
            end
        else
            vim.cmd("colorscheme " .. args.args)
            -- Save non-custom themes too
            save_theme(theme_name)
        end
    end, {
        nargs = 1,
        complete = function(_, _, _)
            -- Combine default themes and custom themes
            local default_themes = vim.fn.getcompletion('', 'color')
            return vim.tbl_extend("force", default_themes, custom_themes)
        end
    })

    -- Try to restore the last used theme
    local saved_theme = load_saved_theme()
    if saved_theme then
        if vim.tbl_contains(custom_themes, saved_theme) then
            if load_custom_theme(saved_theme, false) then
                return -- Successfully restored saved theme
            end
        else
            -- It's a built-in colorscheme
            local success = pcall(function()
                vim.cmd("colorscheme " .. saved_theme)
            end)
            if success then
                return -- Successfully restored saved theme
            end
        end
    end

    -- Fall back to default theme if configured
    if firefly.config.default_theme then
        if vim.tbl_contains(custom_themes, firefly.config.default_theme) then
            load_custom_theme(firefly.config.default_theme, false)
        else
            pcall(function()
                vim.cmd("colorscheme " .. firefly.config.default_theme)
            end)
        end
    else
        -- Load the built-in default theme
        theme.load()
    end
end

-- Get info about the current theme
function firefly.get_current_theme()
    return palette.get_info()
end

return firefly
