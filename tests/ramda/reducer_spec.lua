local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("ramda - reducer", function()
    it("sum of numbers", function()
        local add = function(a, b) return a + b end
        local sumAll = R.reduce(add, 0)

        equal(sumAll({ 1, 2, 3, 4, 5 }), 15)
    end)

    it("to object", function()
        local toObject = R.reduce(function(acc, val, idx)
            acc["key" .. idx] = val
            return acc
        end, {})

        truthy(vim.deep_equal({ key1 = "a", key2 = "b", key3 = "c" }, toObject({ "a", "b", "c" })))
    end)
end)
