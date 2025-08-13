local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

local default_setup = {
    non_sortable_behavior = 'preserve',
}

describe("chadnodes: sort - typescript", function()
    it("should sort with `above` behavior", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort({ non_sortable_behavior = "above" }):stringified_cnodes(), {
            "/**\n * This is a comment\n */",
            "// this is a comment",
            '// this comment "belongs" to the function',
            'function bar() {\n  console.log("bar");\n}',
            'const foo = () => {\n  console.log("foo");\n};'
        }))
    end)

    it("should sort with `below` behavior", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort({ non_sortable_behavior = "below" }):stringified_cnodes(), {
            'function bar() {\n  console.log("bar");\n}',
            'const foo = () => {\n  console.log("foo");\n};',
            "/**\n * This is a comment\n */",
            "// this is a comment",
            '// this comment "belongs" to the function',
        }))
    end)

    it("should sort with `preserve` behavior", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            'function bar() {\n  console.log("bar");\n}',
            'const foo = () => {\n  console.log("foo");\n};',
        }))
    end)

    it("can sort classes", function()
        local mock = typescript_mocks.two_classes
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "class AClass {\n  a: number;\n  constructor(x: number, y: number) {\n    this.a = x;\n  }\n}",
            "class BClass {\n  b: number;\n  constructor(b: number) {\n    this.b = b;\n  }\n}",
        }))
    end)

    it("can sort interfaces", function()
        local mock = typescript_mocks.three_interfaces
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "interface A {\n  a: string;\n}",
            "export interface B {\n  b: number;\n}",
            "export interface C {\n  c: boolean;\n}",
        }))
    end)

    it("can sort peroperties of interfaces", function()
        local mock = typescript_mocks.interface_properties
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "  a: number;",
            "  ;",
            "  b: {\n    foo: string;\n    bar: boolean;\n  }",
            "  c: {\n    baz: string;\n    qux: number;\n    extra: {\n      zig: string;\n    };\n  };",
            "  ;",
        }))
    end)

    it("should keep non-sortable nodes in their place", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            'function bar() {\n  console.log("bar");\n}',
            "// this is a comment",
            'const foo = () => {\n  console.log("foo");\n};'
        }))
    end)

    it("should handle user-defined queries", function()
        local mock = typescript_mocks.prints
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser, {
            expression_statement = [[
                (expression_statement
                  (call_expression
                    function: (member_expression
                      object: (identifier) @object (#eq? @object "console")
                      property: (property_identifier) @property (#eq? @property "log")
                    )
                    (arguments
                      (string (string_fragment) @identifier)
                    )
                  )
                ) @block
            ]]
        })

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "console.log('aaa');",
            "console.log('bbb');",
            "console.log('ccc');",
            "console.log('ddd');",
            "console.log('eee');",
            "console.log('fff');",
        }))
    end)
end)
