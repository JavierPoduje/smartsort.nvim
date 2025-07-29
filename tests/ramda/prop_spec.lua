local R = require("lua.ramda")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal

describe("prop", function()
    it("should return the value of a property", function()
        local obj = { a = 1, b = 2 }
        equal(R.prop("a", obj), 1)
        equal(R.prop("b", obj), 2)
    end)

    it("should return nil if the property does not exist", function()
        local obj = { a = 1, b = 2 }
        equal(R.prop("c", obj), nil)
    end)

    it("should be curried", function()
        local obj = { a = 1, b = 2 }
        local getA = R.prop("a")
        equal(getA(obj), 1)
    end)

    it("should return nil if the object is not a table", function()
        equal(R.prop("a", {}), nil)
        equal(R.prop(123, {}), nil)
    end)

    it("should work with numeric indices", function()
        local list = { 10, 20, 30 }
        equal(R.prop(1, list), 10)
        equal(R.prop(3, list), 30)
        equal(R.prop(4, list), nil)
    end)
end)
