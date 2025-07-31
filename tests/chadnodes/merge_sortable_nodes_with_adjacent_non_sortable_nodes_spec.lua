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
        local merged_cnodes = cnodes:merge_sortable_nodes_with_adjacent_linkable_nodes(mock.region)

        truthy(vim.deep_equal(
            merged_cnodes:debug(bufnr, { include_sort_key = true, include_attached_prefix_cnodes = true }), {
                {
                    attached_prefix_cnodes = { "/**\n * This is a comment\n */" },
                    sort_key = "foo",
                    ts_node = 'const foo = () => {\n  console.log("foo");\n};'
                }, {
                    attached_prefix_cnodes = {},
                    ts_node = "// this is a comment"
                }, {
                    attached_prefix_cnodes = { '// this comment "belongs" to the function' },
                    sort_key = "bar",
                    ts_node = 'function bar() {\n  console.log("bar");\n}'
                }
            }))
    end)
end)
