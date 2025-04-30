local calculate_spaces_between_words = require('smartsort')._calculate_spaces_between_words

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local same = assert.are.same

describe("smartsort._calculate_spaces_between_words", function()
    it("should return an empty list if an string with one word or less is given", function()
        same({}, calculate_spaces_between_words("", ","))
        same({}, calculate_spaces_between_words("thisisatest", ","))
    end)

    it("should return one item per word - 1", function()
        same({ 1 }, calculate_spaces_between_words("test, deez", ","))
        same({ 1, 1, 1 }, calculate_spaces_between_words("this, is, a, test", ","))
    end)

    it("should detect more than one space", function()
        same({ 3 }, calculate_spaces_between_words("test,   deez", ","))
    end)

    it("should detect inconsistent spacing", function()
        same({ 3, 1, 2 }, calculate_spaces_between_words("test,   deez, words,  bruh", ","))
    end)

    it("shouldn't count spaces between non-comma-separated words", function()
        same({ 3, 2 }, calculate_spaces_between_words("test,   deez words,  bruh", ","))
        same({ 1, 2 }, calculate_spaces_between_words("something, other as this,  what's up", ","))
    end)

    it("should detect no-spaces between words", function()
        same({ 0, 0, 0, 1 }, calculate_spaces_between_words(" hola,chao,leorio,caquita, holanda ", ","))
    end)
end)
