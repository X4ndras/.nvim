local ts = require("nvim-treesitter")

local available = {}
for _, lang in ipairs(ts.get_available()) do
    available[lang] = true
end

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

        -- nvim-treesitter doesn't provide this parser.
        if not available[lang] then
            return
        end

        vim.notify(
          ("Installing Tree-sitter parser for %s..."):format(lang),
          vim.log.levels.INFO
        )

        -- Install missing parser automatically.
        ts.install({ lang }):wait(300000)

        if vim.api.nvim_buf_is_valid(buf) then
            start(buf, lang)
        end
    end,
})
