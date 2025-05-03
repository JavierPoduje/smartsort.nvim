local Chadnodes = require("treesitter.chadnodes")
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
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)

    it("get_non_sortable_nodes shouldn't consider sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local non_sortables = cnodes:get_non_sortable_nodes()

        truthy(vim.deep_equal(Chadnodes.from_chadnodes(parser, non_sortables):debug(bufnr), {
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
        }))
    end)

    it("cnode_is_sortable_by_idx recognizes sortable and non-sortable chadnodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        truthy(vim.deep_equal(cnodes:cnode_is_sortable_by_idx(), { true, false, true }))
    end)

    it("merge_sortable_nodes_with_their_comments", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        truthy(vim.deep_equal(cnodes:merge_sortable_nodes_with_their_comments():debug(bufnr),
            { {
                comment_node = "/**\n * This is a comment\n */",
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            }, {
                node = "// this is a comment",
                sortable_idx = ""
            }, {
                comment_node = '// this comment "belongs" to the function',
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            } }
        ))
    end)
end)
