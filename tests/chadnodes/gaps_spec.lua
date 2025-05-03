local Chadnodes = require("treesitter.chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy
--- @diagnostic disable-next-line: undefined-field
local same = assert.are.same

describe("chadnodes: gaps", function()
    it("should detect 'empty' gaps", function()
        local mock = typescript_mocks.without_gap
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:gaps(), { 0 })
    end)

    it("should detect big gaps", function()
        local mock = typescript_mocks.with_bigger_gap
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:gaps(), { 3 })
    end)

    it("should detect more than one gap", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:gaps(), { 1, 1 })
    end)

    it("should consider cnodes with comments", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser):merge_sortable_nodes_with_their_comments()
        same(cnodes:gaps(), { 1, 1 })
    end)
end)
