local Chadnodes = require("chadnodes")
local lua_mocks = require("tests.mocks.lua")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("horizontal gaps", function()
    it("correctly returns gap of 1", function()
        local mock = lua_mocks.simple_gap
        local bufnr, parser = utils.setup(vim.fn.split(mock.content, "\n"), "lua")
        local gaps = Chadnodes.from_region(bufnr, mock.region, parser)
            :merge_sortable_nodes_with_adjacent_linkable_nodes(mock.region)
            :calculate_horizontal_gaps()

        truthy(vim.deep_equal(gaps, { 1 }))
    end)

    it("correctly returns gap of 0", function()
        local mock = lua_mocks.no_gap
        local bufnr, parser = utils.setup(vim.fn.split(mock.content, "\n"), "lua")
        local gaps = Chadnodes.from_region(bufnr, mock.region, parser)
            :merge_sortable_nodes_with_adjacent_linkable_nodes(mock.region)
            :calculate_horizontal_gaps()

        truthy(vim.deep_equal(gaps, { 0 }))
    end)

    it("no horizontal gap equals to -1", function()
        local mock = lua_mocks.third
        local bufnr, parser = utils.setup(vim.fn.split(mock.content, "\n"), "lua")
        local gaps = Chadnodes.from_region(bufnr, mock.region, parser)
            :merge_sortable_nodes_with_adjacent_linkable_nodes(mock.region)
            :calculate_horizontal_gaps()

        truthy(vim.deep_equal(gaps, { -1, 1, -1, 1 }))
    end)
end)
