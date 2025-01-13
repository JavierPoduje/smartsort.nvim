local remove_end_comma = require('smartsort')._remove_end_comma

--- @diagnostic disable-next-line: undefined-global
describe("smartsort._remove_end_comma", function()
    --- @diagnostic disable-next-line: undefined-global
    it("shouldn't do nothing with words without end-comma", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ "word", "another", "w" }, remove_end_comma({ "word", "another", "w" }))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should remove end-comma from words with end-commas", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ "word", "another", "w" }, remove_end_comma({ "word,", "another,", "w," }))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should remove only the last comma, even if a word ends with more that one", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.same({ "some-word,,", "this-guy_" }, remove_end_comma({ "some-word,,,", "this-guy_," }))
    end)
end)
