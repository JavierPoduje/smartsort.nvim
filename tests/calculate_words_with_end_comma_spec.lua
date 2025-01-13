local calculate_words_with_end_comma = require('smartsort')._calculate_words_with_end_comma

describe("smartsort._calculate_words_with_end_comma", function()
    it("should identify words without end-commas", function()
        assert.are.same({ false, false, false }, calculate_words_with_end_comma({ "word", "another_", "w$" }))
    end)

    it("should identify words with end-commas", function()
        assert.are.same({ true, true, true, true },
            calculate_words_with_end_comma({ "word,", "another_,", "w$,", "what's this?,,," }))
    end)
end)
