local remove_end_comma = require('smartsort')._remove_end_comma

describe("smartsort._remove_end_comma", function()
    it("shouldn't do nothing with words without end-comma", function()
        assert.are.same({ "word", "another", "w" }, remove_end_comma({ "word", "another", "w" }))
    end)

    it("should remove end-comma from words with end-commas", function()
        assert.are.same({ "word", "another", "w" }, remove_end_comma({ "word,", "another,", "w," }))
    end)

    it("should remove only the last comma, even if a word ends with more that one", function()
        assert.are.same({ "some-word,,", "this-guy_" }, remove_end_comma({ "some-word,,,", "this-guy_," }))
    end)
end)
