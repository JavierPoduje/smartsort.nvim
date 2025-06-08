local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("ramda - curry", function()
    it("curried add 4", function()
        local add4 = function(a, b, c, d) return a + b + c + d end
        local curriedAdd4 = R.curry(4, add4)

        equal(curriedAdd4(1, 2, 3, 4), 10)
        equal(curriedAdd4(1)(2, 3, 4), 10)
        equal(curriedAdd4(1)(2)(3)(4), 10)
        equal(curriedAdd4(1, 2)(3, 4), 10)
    end)
end)
