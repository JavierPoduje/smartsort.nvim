local Chadnodes = require("treesitter.chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: merge_sortable_nodes_with_adjacent_non_sortable_nodes", function()
    it("merge_sortable_nodes_with_adjacent_non_sortable_nodes", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        local merged_nodes = cnodes:merge_sortable_nodes_with_adjacent_non_sortable_nodes()

        truthy(vim.deep_equal(merged_nodes:debug(bufnr), {
            {
                comment_node = "/**\n * This is a comment\n */",
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
            {
                comment_node = '// this comment "belongs" to the function',
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)
end)
