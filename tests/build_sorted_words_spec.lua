local build_sorted_words = require('smartsort')._build_sorted_words

--- @diagnostic disable-next-line: undefined-global
describe("smartsort._build_sorted_words", function()
    --- @diagnostic disable-next-line: undefined-global
    it("should error if 'spaces_between_words' has a length other than 'words' - 1", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1 }, { true }, { "test", "deez" })
        end)

        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 3 }, { true }, { "what", "about", "deez", "testies" })
        end)

        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1, 1, 1, 1, }, { true }, { "this", "is", "a", "test" })
        end)
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should error if 'words_with_end_comma' has a length other than 'words'", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1, 1 }, { true }, { "this's", "a", "test" })
        end)

        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1, 1 }, { true, false, true, false }, { "this's", "a", "test" })
        end)
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should add comma only to words with comma at the end", function()
        local spaces_between_words = { 1, 1 }
        local words_with_end_comma = { true, false, true }
        local words = { "this", "is", "a" }
        --- @diagnostic disable-next-line: undefined-field
        assert.are.equals("this, is a,", build_sorted_words(spaces_between_words, words_with_end_comma, words))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should respect spaces between words", function()
        local spaces_between_words = { 1, 2, 3 }
        local words_with_end_comma = { true, false, true, false }
        local words = { "this", "is", "a", "test" }
        --- @diagnostic disable-next-line: undefined-field
        assert.are.equals("this, is  a,   test", build_sorted_words(spaces_between_words, words_with_end_comma, words))
    end)
end)
