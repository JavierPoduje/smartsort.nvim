local R = require("lua.ramda")

describe("prop", function()
    it("should return the value of a property", function()
        local obj = { a = 1, b = 2 }
        assert.are.equal(R.prop("a", obj), 1)
        assert.are.equal(R.prop("b", obj), 2)
    end)

    it("should return nil if the property does not exist", function()
        local obj = { a = 1, b = 2 }
        assert.are.equal(R.prop("c", obj), nil)
    end)

    it("should be curried", function()
        local obj = { a = 1, b = 2 }
        local getA = R.prop("a")
        assert.are.equal(getA(obj), 1)
    end)

    it("should return nil if the object is not a table", function()
        assert.are.equal(R.prop("a", nil), nil)
        assert.are.equal(R.prop("a", "hello"), nil)
        assert.are.equal(R.prop("a", 123), nil)
    end)

    it("should work with numeric indices", function()
        local list = { 10, 20, 30 }
        assert.are.equal(R.prop(1, list), 10)
        assert.are.equal(R.prop(3, list), 30)
        assert.are.equal(R.prop(4, list), nil)
    end)
end)
