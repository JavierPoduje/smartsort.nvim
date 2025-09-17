local Chadnodes = require("chadnodes")
local javascript_mocks = require("tests.mocks.javascript")
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

describe("chadnodes: sort - javascript", function()
    it("should sort switch statements", function()
        local mock = javascript_mocks.class_declaration
        local bufnr, parser = utils.setup(mock.content, "javascript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sorted_cnodes = cnodes:sort(default_setup)

        truthy(vim.deep_equal(sorted_cnodes:stringified_cnodes(), {
            "class Apple {\n  // implementation\n}",
            "export class Banana {\n  // implementation\n}",
            "class Zebra {\n  // implementation\n}",
        }))
    end)

    it("should sort field_definitions", function()
        local mock = javascript_mocks.field_definition
        local bufnr, parser = utils.setup(mock.content, "javascript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sorted_cnodes = cnodes:sort(default_setup)

        truthy(vim.deep_equal(sorted_cnodes:stringified_cnodes(), {
            '    apple = "apple";',
            "                   ;",
            '    banana = "banana";',
            "                   ;",
            '    zebra = "zebra";',
            "                     ;"
        }))
    end)

    it("should sort object pairs", function()
        local mock = javascript_mocks.pair
        local bufnr, parser = utils.setup(mock.content, "javascript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sorted_cnodes = cnodes:sort(default_setup)

        truthy(vim.deep_equal(sorted_cnodes:stringified_cnodes(), {
            "  aaa,",
            "            ,",
            "  bbb: 'bbb',",
            "     ,",
        }))
    end)
end)
