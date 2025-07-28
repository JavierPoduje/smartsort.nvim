local Container = require('adequate.container')

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equals = assert.are.equals


describe("adequate's container", function()
    it("should sum values correctly", function()
        local double = function(a) return a * 2 end
        equals(4, Container.of(2):map(double).value)
    end)

    it("should uppercase correctly", function()
        local upper = function(a) return a:upper() end
        equals('FLAMETHROWERS', Container.of('flamethrowers'):map(upper).value)
    end)

    it("should be able to concat maps", function()
        local str_append = function(a) return a .. " away" end
        equals(10, Container.of('bombs'):map(str_append):map(function(input) return #input end).value)
    end)
end)
