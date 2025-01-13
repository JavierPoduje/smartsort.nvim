local calculate_spaces_between_words = require('smartsort')._calculate_spaces_between_words

describe("smartsort._calculate_spaces_between_words", function()
    it("should return an empty list if an string with one word or less is given", function()
        assert.are.same({}, calculate_spaces_between_words(""))
        assert.are.same({}, calculate_spaces_between_words("thisisatest"))
    end)

    it("should return one item per word - 1", function()
        assert.are.same({ 1 }, calculate_spaces_between_words("test deez"))
        assert.are.same({ 1, 1, 1 }, calculate_spaces_between_words("this is a test"))
    end)

    it("should detect more than one space", function()
        assert.are.same({ 3 }, calculate_spaces_between_words("test   deez"))
    end)

    it("should detect inconsistent spacing", function()
        assert.are.same({ 3, 1, 2 }, calculate_spaces_between_words("test   deez words,  bruh"))
    end)
end)
