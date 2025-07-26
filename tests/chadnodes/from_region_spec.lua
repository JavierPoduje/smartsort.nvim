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

        truthy(cnodes:__tostring(), [[
const foo = () => {
  console.log("foo");
};
// this is a comment
function bar() {
  console.log("bar");
}
        ]])
    end)

    it("should grab function comments", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                ts_node = "/**\n * This is a comment\n */",
                sort_key = ""
            },
            {
                ts_node = 'const foo = () => {\n  console.log("foo");\n};',
                sort_key = "foo"
            },
            {
                ts_node = "// this is a comment",
                sort_key = ""
            },
            {
                ts_node = '// this comment "belongs" to the function',
                sort_key = ""
            },
            {
                ts_node = 'function bar() {\n  console.log("bar");\n}',
                sort_key = "bar"
            }
        }))
    end)

    it("shouldn't consider nodes outside region - start", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, Region.new(1, 1, 3, 1), parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                ts_node = 'const foo = () => {\n  console.log("foo");\n};',
                sort_key = "foo"
            },
        }))
    end)

    it("shouldn't consider nodes outside region - end", function()
        local mock = typescript_mocks.middle_size
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:debug(bufnr), {
            {
                ts_node = "// this is a comment",
                sort_key = ""
            },
            {
                ts_node = "// comment attached to the function zit",
                sort_key = ""
            },
            {
                ts_node = 'const zit = () => {\n  console.log("zit");\n};',
                sort_key = "zit"
            },
            {
                ts_node = "// nested comment",
                sort_key = ""
            },
            {
                ts_node = "/**\n * This is a comment\n */",
                sort_key = ""
            },
            {
                ts_node = 'function bar() {\n  console.log("bar");\n}',
                sort_key = "bar"
            }
        }))
    end)
end)
