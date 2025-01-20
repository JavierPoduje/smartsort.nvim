local f = require("funcs")
local parsers = require("nvim-treesitter.parsers")
local typescript_mocks = require("tests.mocks.typescript")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal

--- @param buf_content string[]: the content of the buffer
--- @return number, vim.treesitter.LanguageTree
local setup = function(buf_content)
    vim.cmd(":new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_content)

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    -- set filetype
    local filetype = "typescript"
    vim.bo[bufnr].filetype = filetype

    -- set parser
    local parser = parsers.get_parser(bufnr, filetype)
    if not parser then
        error("Parser not available for filetype: " .. filetype)
    end
    parser:parse()

    return bufnr, parser
end

describe("utils", function()
    it("get_line_indent should recognize identation properly", function()
        local mock = typescript_mocks.simplest
        local bufnr, _ = setup(mock.content)
        local identation = f.get_line_indent(bufnr, 1)
        equal(identation, "  ")
    end)

    it("get_line_indent should recognize no identation properly", function()
        local mock = typescript_mocks.simplest
        local bufnr, _ = setup(mock.content)
        local identation = f.get_line_indent(bufnr, 0)
        equal(identation, "")
    end)
end)
