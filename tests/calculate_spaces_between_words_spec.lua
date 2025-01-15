local calculate_spaces_between_words = require('smartsort')._calculate_spaces_between_words

--- @diagnostic disable-next-line: undefined-global
describe("smartsort._calculate_spaces_between_words", function()
    --- @diagnostic disable-next-line: undefined-global
    it("should return an empty list if an string with one word or less is given", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({}, calculate_spaces_between_words(""))
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({}, calculate_spaces_between_words("thisisatest"))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should return one item per word - 1", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 1 }, calculate_spaces_between_words("test, deez"))
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 1, 1, 1 }, calculate_spaces_between_words("this, is, a, test"))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should detect more than one space", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 3 }, calculate_spaces_between_words("test,   deez"))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should detect inconsistent spacing", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 3, 1, 2 }, calculate_spaces_between_words("test,   deez, words,  bruh"))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("shouldn't count spaces between non-comma-separated words", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 3, 2 }, calculate_spaces_between_words("test,   deez words,  bruh"))
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 1, 2 }, calculate_spaces_between_words("something, other as this,  what's up"))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should detect no-spaces between words", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ 0, 0, 0, 1 }, calculate_spaces_between_words(" hola,chao,leorio,caquita, holanda "))
    end)
end)
