local Chadnodes = require("chadnodes")
local f = require("funcs")
local lua_mocks = require("tests.mocks.lua")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

local default_setup = utils.default_setup

describe("chadnodes: sort - lua", function()
    it("should consider vertical and horizontal gaps properly", function()
        local mock = lua_mocks.third
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser)
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            "    aBoolean = true,",
            "    ,",
            '    aaa = "value of aaa",',
            "    ,",
            '    anotherValue = { "value1", "value2", },',
            "    ,",
            '    someValue = "value",',
            "    ,",
            "    -- some comment",
        }))
    end)

    it("should sort alphabetically", function()
        local mock = lua_mocks.simple
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser)
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            'M.a = function()\n    print("another guy called a")\nend',
            'M.b = function()\n    print("this is b")\nend',
        }))
    end)

    it("can sort variable declarations", function()
        local mock = lua_mocks.variables
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser)
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            'local varA = "something"',
            "--- @type boolean",
            "local varB = false",
            "--- @type string",
            'local varC = "something"',
        }))
    end)
end)
