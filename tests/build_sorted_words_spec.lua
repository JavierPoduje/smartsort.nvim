local build_sorted_words = require('smartsort')._build_sorted_words

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equals = assert.are.equals
--- @diagnostic disable-next-line: undefined-field
local has_error = assert.has_error

describe("smartsort._build_sorted_words", function()
    it("should error if 'spaces_between_words' has a length other than 'words' - 1", function()
        has_error(function() build_sorted_words({ 1, 1 }, { "test", "deez" }) end)
        has_error(function() build_sorted_words({ 3 }, { "what", "about", "deez", "testies" }) end)
        has_error(function() build_sorted_words({ 1, 1, 1, 1, 1, }, { "this", "is", "a", "test" }) end)
    end)

    it("should respect spaces between words", function()
        equals(
            "this, is,  a,   test",
            build_sorted_words({ 1, 2, 3 }, { "this", "is", "a", "test" })
        )
    end)

    it("should respect non-alphanumeric characters", function()
        equals(
            '"c", "ss", require(\'smartsort\').sort',
            build_sorted_words({ 1, 1 }, { '"c"', '"ss"', "require('smartsort').sort" })
        )
    end)
end)
