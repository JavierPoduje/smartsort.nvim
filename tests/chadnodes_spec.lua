local Chadnodes = require("treesitter.chadnodes")
local Region = require("region")
local parsers = require("nvim-treesitter.parsers")
local typescript_mocks = require("tests.mocks.typescript")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

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

describe("chadnodes", function()
    describe("from_region", function()
        it("should recognize non-sortable nodes", function()
            local mock = typescript_mocks.with_comment
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

            truthy(vim.deep_equal(cnodes:debug(bufnr), {
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
                {
                    node = "// this is a comment",
                    sortable_idx = ""
                },
                {
                    node = 'function bar() {\n  console.log("bar");\n}',
                    sortable_idx = "bar"
                }
            }))
        end)

        it("shouldn't consider nodes outside region", function()
            local mock = typescript_mocks.simplest
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, Region.new(1, 1, 3, 1), parser)

            truthy(vim.deep_equal(cnodes:debug(bufnr), {
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
            }))
        end)
    end)
end)
