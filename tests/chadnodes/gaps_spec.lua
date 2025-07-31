local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local lua_mocks = require("tests.mocks.lua")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local same = assert.are.same


describe("chadnodes: gaps", function()
    it("should detect 'empty' gaps", function()
        local mock = typescript_mocks.without_gap
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:calculate_vertical_gaps(), { 0 })
    end)

    it("should detect big gaps", function()
        local mock = typescript_mocks.with_bigger_gap
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:calculate_vertical_gaps(), { 3 })
    end)

    it("should detect more than one gap", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        same(cnodes:calculate_vertical_gaps(), { 1, 1 })
    end)

    it("lua gaps", function()
        local mock = lua_mocks.module
        local bufnr, parser = utils.setup(vim.fn.split(mock.content, "\n"), "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        same(cnodes:calculate_vertical_gaps(), { 1 })
    end)
end)
