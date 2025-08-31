local Chadnodes = require("chadnodes")
local go_mocks = require("tests.mocks.go")
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

describe("chadnodes: sort - go", function()
    it("should sort switch statements", function()
        local mock = go_mocks.switch_statement
        local bufnr, parser = utils.setup(mock.content, "go")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sorted_cnodes = cnodes:sort(default_setup)

        truthy(vim.deep_equal(sorted_cnodes:stringified_cnodes(), {
            ' case bool:\n\t\tfmt.Println("bool")',
            ' case int:\n\t\tfmt.Println("int")',
            ' case string:\n\t\tfmt.Println("string")',
        }))
    end)
end)
