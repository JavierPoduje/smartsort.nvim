local Chadnodes = require("treesitter.chadnodes")
local lua_mocks = require("tests.mocks.lua")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort - lua", function()
    it("should sort alphabetically", function()
        local mock = lua_mocks.simple
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'M.a = function()\n    print("another guy called a")\nend',
                sortable_idx = "a"
            },
            {
                node = 'M.b = function()\n    print("this is b")\nend',
                sortable_idx = "b"
            }
        }))
    end)

    it("can sort variable declarations", function()
        local mock = lua_mocks.variables
        local bufnr, parser = utils.setup(mock.content, "lua")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = 'local varA = "something"',
                sortable_idx = "varA"
            },
            {
                node = "--- @type boolean",
                sortable_idx = ""
            },
            {
                node = "local varB = false",
                sortable_idx = "varB"
            },
            {
                node = "--- @type string",
                sortable_idx = ""
            },
            {
                node = 'local varC = "something"',
                sortable_idx = "varC"
            }
        }))
    end)
end)
