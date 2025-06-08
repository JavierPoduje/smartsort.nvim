local R = require 'ramda'

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("ramda - equals", function()
    it("equals usage - numbers", function()
        equal(R.equals(1, 1), true)
        equal(R.equals(2, 1), false)

        equal(R.equals({ 1, 2 }, { 1, 2 }), true)
        equal(R.equals({ 1, 2 }, { 1, 3 }), false)
    end)

    it("equals usage - strings", function()
        equal(R.equals("hello", "hello"), true)
        equal(R.equals("hello", "world"), false)
    end)

    it("equals usage - arrays", function()
        equal(R.equals({ 1, 2 }, { 1, 2 }), true)
        equal(R.equals({ 1, 2 }, { 1, 3 }), false)
    end)

    it("equals usage - tables", function()
        equal(R.equals({ a = 1, b = 2 }, { b = 2, a = 1 }), true)
        equal(R.equals({ a = 1, b = 2 }, { b = 2, a = 3 }), false)
    end)
end)
