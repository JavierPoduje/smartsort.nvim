local build_sorted_words = require('smartsort')._build_sorted_words

describe("smartsort._build_sorted_words", function()
    it("should error if 'spaces_between_words' has a length other than 'words' - 1", function()
        assert.has_error(function()
            build_sorted_words({ 1, 1 }, { true }, { "test", "deez" })
        end)

        assert.has_error(function()
            build_sorted_words({ 3 }, { true }, { "what", "about", "deez", "testies" })
        end)

        assert.has_error(function()
            build_sorted_words({ 1, 1, 1, 1, 1, }, { true }, { "this", "is", "a", "test" })
        end)
    end)

    it("should error if 'words_with_end_comma' has a length other than 'words'", function()
        assert.has_error(function()
            build_sorted_words({ 1, 1, 1 }, { true }, { "this's", "a", "test" })
        end)

        assert.has_error(function()
            build_sorted_words({ 1, 1, 1 }, { true, false, true, false }, { "this's", "a", "test" })
        end)
    end)

    it("should add comma only to words with comma at the end", function()
        local spaces_between_words = { 1, 1 }
        local words_with_end_comma = { true, false, true }
        local words = { "this", "is", "a" }
        assert.are.equals("this, is a,", build_sorted_words(spaces_between_words, words_with_end_comma, words))
    end)

    it("should respect spaces between words", function()
        local spaces_between_words = { 1, 2, 3 }
        local words_with_end_comma = { true, false, true, false }
        local words = { "this", "is", "a", "test" }
        assert.are.equals("this, is  a,   test", build_sorted_words(spaces_between_words, words_with_end_comma, words))
    end)
end)
