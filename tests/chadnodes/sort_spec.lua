local Chadnodes = require("treesitter.chadnodes")
local lua_mocks = require("tests.mocks.lua")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort", function()
    it("typescript - should sort alphabetically", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            },
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
        }))
    end)

    it("lua - should sort alphabetically", function()
        local mock = lua_mocks.simple
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'M.a = function()\n    print("another guy called a")\nend',
                sortable_idx = "a"
            },
            {
                node = 'M.b = function()\n    print("this is b")\nend',
                sortable_idx = "b"
            }
        }))
    end)

    it("lua - can sort variable declarations", function()
        local mock = lua_mocks.variables
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'local varA = "something"',
                sortable_idx = "varA"
            },
            {
                node = "--- @type boolean",
                sortable_idx = ""
            },
            {
                node = "local varB = false",
                sortable_idx = "varB"
            },
            {
                node = "--- @type string",
                sortable_idx = ""
            },
            {
                node = 'local varC = "something"',
                sortable_idx = "varC"
            }
        }))
    end)

    it("typescript - can sort classes", function()
        local mock = typescript_mocks.two_classes
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "class AClass {\n  a: number;\n  constructor(x: number, y: number) {\n    this.a = x;\n  }\n}",
                sortable_idx = "AClass"
            },
            {
                node = "class BClass {\n  b: number;\n  constructor(b: number) {\n    this.b = b;\n  }\n}",
                sortable_idx = "BClass"
            },
        }))
    end)

    it("typescript - can sort interfaces", function()
        local mock = typescript_mocks.three_interfaces
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "interface A {\n  a: string;\n}",
                sortable_idx = "A"
            },
            {
                node = "export interface B {\n  b: number;\n}",
                sortable_idx = "B"
            },
            {
                node = "export interface C {\n  c: boolean;\n}",
                sortable_idx = "C"
            },
        }))
    end)

    it("typescript - can sort peroperties of interfaces", function()
        local mock = typescript_mocks.interface_properties
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "a: number",
                sortable_idx = "a"
            },
            {
                node = ";",
                sortable_idx = ""
            },
            {
                node = "b: {\n    foo: string;\n    bar: boolean;\n  }",
                sortable_idx = "b"
            },
            {
                node = "c: {\n    baz: string;\n    qux: number;\n    extra: {\n      zig: string;\n    };\n  }",
                sortable_idx = "c"
            },
            {
                node = ";",
                sortable_idx = ""
            },
        }))
    end)

    it("should keep non-sortable nodes in their place", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            },
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
        }))
    end)
end)
