local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: merge_sortable_nodes_with_adjacent_linkable_nodes", function()
    it("merge_sortable_nodes_with_adjacent_linkable_nodes", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        local merged_nodes = cnodes:merge_sortable_nodes_with_adjacent_linkable_nodes()

        truthy(vim.deep_equal(merged_nodes:debug(bufnr), {
            {
                attached_prefix_cnode = "/**\n * This is a comment\n */",
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
            {
                attached_prefix_cnode = '// this comment "belongs" to the function',
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)
end)
