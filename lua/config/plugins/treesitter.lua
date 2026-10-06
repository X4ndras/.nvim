local ts = require("nvim-treesitter")

local available = {}
for _, lang in ipairs(ts.get_available()) do
    available[lang] = true
end

local attempted = {}
local warned_cli = false

local function start(buf, lang)
    -- Check whether a parser already exists somewhere on runtimepath.
    if not vim.treesitter.language.add(lang) then
        return false
    end

    -- Tree-sitter highlighting.
    vim.treesitter.start(buf, lang)

    -- Tree-sitter indentation.
    vim.bo[buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"

    return true
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",

    callback = function(event)
        local buf = event.buf
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)

        if not lang then
            return
        end

        -- Already installed: just start it.
        if start(buf, lang) then
            return
        end

        -- nvim-treesitter doesn't provide this parser, or we already tried.
        if not available[lang] or attempted[lang] then
            return
        end
        attempted[lang] = true

        -- Building parsers requires the tree-sitter CLI (brew install tree-sitter-cli).
        if vim.fn.executable("tree-sitter") == 0 then
            if not warned_cli then
                warned_cli = true
                vim.notify(
                    "tree-sitter CLI not found; skipping parser auto-install",
                    vim.log.levels.WARN
                )
            end
            return
        end

        vim.notify(
          ("Installing Tree-sitter parser for %s..."):format(lang),
          vim.log.levels.INFO
        )

        -- Install missing parser automatically, without blocking the UI.
        ts.install({ lang }):await(function(err, ok)
            if err or not ok then
                return
            end
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    start(buf, lang)
                end
            end)
        end)
    end,
})
