local Chadnodes = require("chadnodes")
local parsers = require("nvim-treesitter.parsers")
local typescript_mocks = require("tests.mocks.typescript")

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

--- @diagnostic disable-next-line: undefined-global
describe("chadnodes", function()
    --- @diagnostic disable-next-line: undefined-global
    it("from_region", function()
        local mock = typescript_mocks.without_gap
        local bufnr, parser = setup(mock.content)
    end)
end)
