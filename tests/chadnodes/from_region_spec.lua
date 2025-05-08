local Chadnodes = require("chadnodes")
local Region = require("region")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: from_region", function()
    it("should recognize non-sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
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

    it("should grab function comments", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                node = "/**\n * This is a comment\n */",
                sortable_idx = ""
            },
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
            {
                node = '// this comment "belongs" to the function',
                sortable_idx = ""
            },
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)

    it("shouldn't consider nodes outside region - start", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, Region.new(1, 1, 3, 1), parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
        }))
    end)

    it("shouldn't consider nodes outside region - end", function()
        local mock = typescript_mocks.middle_size
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
            {
                node = "// comment attached to the function zit",
                sortable_idx = ""
            },
            {
                node = 'const zit = () => {\n  console.log("zit");\n};',
                sortable_idx = "zit"
            },
            {
                node = "// nested comment",
                sortable_idx = ""
            },
            {
                node = "/**\n * This is a comment\n */",
                sortable_idx = ""
            },
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)
end)
