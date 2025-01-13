local calculate_words_with_end_comma = require('smartsort')._calculate_words_with_end_comma

--- @diagnostic disable-next-line: undefined-global
describe("smartsort._calculate_words_with_end_comma", function()
    --- @diagnostic disable-next-line: undefined-global
    it("should identify words without end-commas", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ false, false, false }, calculate_words_with_end_comma({ "word", "another_", "w$" }))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should identify words with end-commas", function()
        --- @diagnostic disable: undefined-field
        assert.are.same({ true, true, true, true },
            calculate_words_with_end_comma({ "word,", "another_,", "w$,", "what's this?,,," }))
    end)
end)
