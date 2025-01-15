local build_sorted_words = require('smartsort')._build_sorted_words

--- @diagnostic disable-next-line: undefined-global
describe("smartsort._build_sorted_words", function()
    --- @diagnostic disable-next-line: undefined-global
    it("should error if 'spaces_between_words' has a length other than 'words' - 1", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1 }, { "test", "deez" })
        end)

        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 3 }, { "what", "about", "deez", "testies" })
        end)

        --- @diagnostic disable-next-line: undefined-field
        assert.has_error(function()
            build_sorted_words({ 1, 1, 1, 1, 1, }, { "this", "is", "a", "test" })
        end)
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should respect spaces between words", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.equals("this, is,  a,   test", build_sorted_words({ 1, 2, 3 }, { "this", "is", "a", "test" }))
    end)

    --- @diagnostic disable-next-line: undefined-global
    it("should respect non-alphanumeric characters", function()
        --- @diagnostic disable-next-line: undefined-field
        assert.are.equals('"c", "ss", require(\'smartsort\').sort',
            build_sorted_words({ 1, 1 }, { '"c"', '"ss"', "require('smartsort').sort" }))
    end)
end)
