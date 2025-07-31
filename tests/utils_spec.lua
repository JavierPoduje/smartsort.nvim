local f = require("funcs")
local typescript_mocks = require("tests.mocks.typescript")
local setup = require("tests.utils").setup


--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal


describe("utils", function()
    it("get_line_indent should recognize identation properly", function()
        local mock = typescript_mocks.simplest
        local bufnr, _ = setup(vim.fn.split(mock.content, "\n"), "typescript")
        local identation = f.get_line_indent(bufnr, 1)
        equal(identation, "  ")
    end)

    it("get_line_indent should recognize no identation properly", function()
        local mock = typescript_mocks.simplest
        local bufnr, _ = setup(vim.fn.split(mock.content, "\n"), "typescript")
        local identation = f.get_line_indent(bufnr, 0)
        equal(identation, "")
    end)
end)
