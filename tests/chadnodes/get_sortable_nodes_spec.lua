local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes", function()
    it("get_sortable_nodes shouldn't consider non-sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sortables = cnodes:get_sortable_nodes()

        truthy(vim.deep_equal(Chadnodes.from_chadnodes(parser, sortables):debug(bufnr), {
            {
                ts_node = 'const foo = () => {\n  console.log("foo");\n};',
                sort_key = "foo"
            },
            {
                ts_node = 'function bar() {\n  console.log("bar");\n}',
                sort_key = "bar"
            }
        }))
    end)
end)
