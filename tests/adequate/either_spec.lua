local either = require('adequate.either')
local R = require('ramda')
local Either = either.Either
local Left = either.Left

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equals = assert.are.equals

describe("adequate's either", function()
    it("should apply function normally if it's Right", function()
        local value = Either.of('rain')
        local output = value:map(function(str) return 'b' .. str end)
        equals("Right('brain')", output:inspect())
    end)

    it("should skip function apply if it's Left", function()
        local value = Left.left('rain')
        local output = value:map(function(str) return 'It\'s gonna ' .. str .. ', better bring your umbrella!' end)
        equals("Left('rain')", output:inspect())
    end)

    it("should support tables", function()
        local value = Either.of({ host = 'localhost', port = 80 })
        local output = value:map(R.prop('host'))
        equals("Right('localhost')", output:inspect())
    end)

    it("should not apply func on Left, so this shouldn't fail", function()
        local value = Left.left('rolls eyes...')
        local output = value:map(R.prop('host'))
        equals("Left('rolls eyes...')", output:inspect())
    end)
end)
