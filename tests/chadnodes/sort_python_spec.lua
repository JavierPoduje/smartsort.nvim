local Chadnodes = require("chadnodes")
local python_mocks = require("tests.mocks.python")
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

describe("chadnodes: sort - python", function()
    it("can sort assignments", function()
        local mock = python_mocks.two_assignments
        local bufnr, parser = utils.setup(mock.content, "python")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        cnodes:sort(default_setup):print()

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "bar = \"bar\"",
            "foo = \"foo\"",
        }))
    end)

    it("can sort functions", function()
        local mock = python_mocks.two_functions
        local bufnr, parser = utils.setup(mock.content, "python")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "def bar():\n    print(\"bar\")",
            "def foo():\n    print(\"foo\")",
        }))
    end)

    it("can sort classes", function()
        local mock = python_mocks.two_classes
        local bufnr, parser = utils.setup(mock.content, "python")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "class AClass:\n    def __init__(self, a):\n        self.a = a",
            "class BClass:\n    def __init__(self, b):\n        self.b = b",
        }))
    end)
end)
