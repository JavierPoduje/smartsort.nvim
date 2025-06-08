local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("ramda - placeholder", function()
    it("Placeholder usage", function()
        local add4 = function(a, b, c, d) return a + b + c + d end
        local curriedAdd4 = R.curry(4, add4)
        local f1 = curriedAdd4(R.__, 2, R.__, 4)
        local f2 = f1(1, R.__)
        local f3 = f2(3)

        equal(f3, 10)
    end)
end)
