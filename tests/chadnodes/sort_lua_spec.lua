local Chadnodes = require("chadnodes")
local Region = require("region")
local lua_mocks = require("tests.mocks.lua")
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

describe("chadnodes: sort - lua", function()
    it("should consider vertical and horizontal gaps properly", function()
        local mock = lua_mocks.third
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        print(vim.inspect(cnodes:sort(default_setup):stringified_cnodes()))

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            "    aBoolean = true,",
            "                       ,",
            '                                            aaa = "value of aaa",',
            "                                          ,",
            '    anotherValue = { "value1", "value2", },',
            "                                                                ,",
            '    someValue = "value",',
            "                   ,",
            "                     -- some comment",
        }))
    end)

    it("should sort alphabetically", function()
        local mock = lua_mocks.simple
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            'M.a = function()\n    print("another guy called a")\nend',
            'M.b = function()\n    print("this is b")\nend',
        }))
    end)

    it("can sort variable declarations", function()
        local mock = lua_mocks.variables
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(), {
            'local varA = "something"',
            "--- @type boolean",
            "local varB = false",
            "--- @type string",
            'local varC = "something"',
        }))
    end)

    it("should sort different function definition types", function()
        local mock = lua_mocks.module
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, Region.new(3, 1, 22, 3), parser)

        truthy(vim.deep_equal(cnodes:sort(default_setup):stringified_cnodes(),
            {
                "--- Module for various functions",
                "--- @return table",
                'M.__tostring = function(self)\n    return "Functions module"\nend',
                '--- Prints "something" to the console',
                "--- @return nil",
                "function M:new()\n    local o = {}\n    setmetatable(o, self)\n    self.__index = self\n    return o\nend",
                "--- Returns a string representation of the module",
                "--- @return string",
                'M.printsomething = function(self)\n    print("something")\nend'
            }
        ))
    end)
end)
