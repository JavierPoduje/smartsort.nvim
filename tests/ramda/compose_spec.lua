local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("ramda - compose", function()
    it("compose usage 1", function()
        local increment = function(n) return n + 1 end
        local double = function(n) return n * 2 end
        local toString = function(n) return tostring(n) end

        local composedFn = R.compose(toString, double, increment)

        equal(composedFn(5), '12')
    end)

    it("compose usage 2", function()
        local increment = function(n) return n + 1 end
        local double = function(n) return n * 2 end

        local addThenMultiply = R.compose(double, increment)

        equal(addThenMultiply(5), 12)
    end)

    it("compose usage 3", function()
        local double = function(n) return n * 2 end
        local toString = function(n) return tostring(n) end
        local sumAndThenDoubleCompose = R.compose(
            toString,
            double,
            function(a, b) return a + b end
        )

        equal(sumAndThenDoubleCompose(3, 7), '20')
    end)
end)
