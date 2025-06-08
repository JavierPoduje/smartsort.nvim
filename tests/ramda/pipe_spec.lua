local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("ramda - pipe", function()
    it("pipe usage 1", function()
        local add1 = function(n) return n + 1 end
        local double = function(n) return n * 2 end
        local toString = function(n) return tostring(n) end

        local pipedFn = R.pipe(add1, double, toString)

        equal(pipedFn(5), '12')
    end)

    it("pipe usage 2", function()
        local greet = function(name) return "Hello, " .. name end
        local toUpper = function(s) return string.upper(s) end
        local exclaim = function(s) return s .. "!" end

        local loudGreeting = R.pipe(greet, toUpper, exclaim)

        equal(loudGreeting("Alice"), "HELLO, ALICE!")
    end)

    it("pipe usage 3", function()
        local double = function(n) return n * 2 end
        local toString = function(n) return tostring(n) end
        local sumAndThenDouble = R.pipe(
            function(a, b) return a + b end, -- Takes two args
            double,
            toString
        )

        equal(sumAndThenDouble(3, 7), "20")
    end)
end)
