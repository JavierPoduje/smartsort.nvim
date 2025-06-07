local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort - typescript", function()
    it("should sort alphabetically", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sort_key = "bar"
            },
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sort_key = "foo"
            },
        }))
    end)

    it("can sort classes", function()
        local mock = typescript_mocks.two_classes
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "class AClass {\n  a: number;\n  constructor(x: number, y: number) {\n    this.a = x;\n  }\n}",
                sort_key = "AClass"
            },
            {
                node = "class BClass {\n  b: number;\n  constructor(b: number) {\n    this.b = b;\n  }\n}",
                sort_key = "BClass"
            },
        }))
    end)

    it("can sort interfaces", function()
        local mock = typescript_mocks.three_interfaces
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "interface A {\n  a: string;\n}",
                sort_key = "A"
            },
            {
                node = "export interface B {\n  b: number;\n}",
                sort_key = "B"
            },
            {
                node = "export interface C {\n  c: boolean;\n}",
                sort_key = "C"
            },
        }))
    end)

    it("can sort peroperties of interfaces", function()
        local mock = typescript_mocks.interface_properties
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "a: number",
                sort_key = "a"
            },
            {
                node = ";",
                sort_key = ""
            },
            {
                node = "b: {\n    foo: string;\n    bar: boolean;\n  }",
                sort_key = "b"
            },
            {
                node = "c: {\n    baz: string;\n    qux: number;\n    extra: {\n      zig: string;\n    };\n  }",
                sort_key = "c"
            },
            {
                node = ";",
                sort_key = ""
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
                sort_key = "bar"
            },
            {
                node = "// this is a comment",
                sort_key = ""
            },
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sort_key = "foo"
            },
        }))
    end)
end)
