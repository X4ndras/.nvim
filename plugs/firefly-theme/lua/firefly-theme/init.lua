local firefly = { }

local theme = require("firefly-theme.theme")
local palette= require("firefly-theme.palette")

function firefly.colorize()
    --print("loading devel")

    -- read themes folder
    local themes_dir = vim.fn.stdpath("config") .. "/themes"

    -- extend custom themes
    -- Scan themes directory for JSON files
    local function scan_themes()
        local themes = {}
        local handle = vim.loop.fs_scandir(themes_dir)
        if handle then
            while true do
                local name, _ = vim.loop.fs_scandir_next(handle)
                if not name then break end

                -- Check for .json files and extract theme name
                if name:match("%.json$") then
                    local theme_name = name:gsub("%.json$", "")
                    table.insert(themes, theme_name)
                end
            end
        end
        return themes
    end

    local custom_themes = scan_themes()

    vim.api.nvim_create_user_command("Colorscheme", function(args)
        local theme_name = args.args

        if vim.tbl_contains(custom_themes, theme_name) then
            local theme_path = string.format("%s/%s.json", themes_dir, theme_name)
            -- Read theme file
            local success = pcall(function()
                palette.read_theme(theme_path)
            end)
            if success then
                theme.load()
            else
                print("Error loading theme from json: " .. theme_name)
            end
        else
            vim.cmd("colorscheme " .. args.args)
        end
    end, {
      nargs = 1,
      complete = function(_, _, _)
        -- Combine default themes and custom themes
        local default_themes = vim.fn.getcompletion('', 'color')
        return vim.tbl_extend("force", default_themes, custom_themes)
      end
    })

    theme.load()
end

return firefly
