local Chadnodes = require("treesitter.chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort", function()
    it("should sort alphabetically", function()
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

    it("can sort typescript classes", function()
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

    it("can sort typescript interfaces", function()
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
