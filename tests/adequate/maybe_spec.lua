local Maybe = require('adequate.maybe')

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equals = assert.are.equals

describe("adequate's maybe", function()
    it("should return Nothing for nil values", function()
        local nothing = Maybe.of(nil)
        equals('Nothing', nothing:inspect())
        equals(true, nothing:isNothing())
    end)

    it("should return Just for non-nil values", function()
        local just = Maybe.of(42)
        equals('Just(42)', just:inspect())
        equals(false, just:isNothing())
    end)

    it("should map over Just values", function()
        local just = Maybe.of(3)
        local result = just:map(function(x) return x * 2 end)
        equals('Just(6)', result:inspect())
    end)

    it("should return Nothing when mapping over Nothing", function()
        local nothing = Maybe.of(nil)
        local result = nothing:map(function(x) return x * 2 end)
        equals('Nothing', result:inspect())
    end)
end)
