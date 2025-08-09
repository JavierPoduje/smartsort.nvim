local SinglelineSorter = require('singleline_sorter')

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equals = assert.are.equals
--- @diagnostic disable-next-line: undefined-field
local has_error = assert.has_error
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("smartsort._build_sorted_words", function()
    it("should error if 'spaces_between_words' has a length other than 'words' - 1", function()
        local slsorter = SinglelineSorter.new(",")

        has_error(function()
            slsorter:_build_sorted_words({ 1, 1 }, { "test", "deez" })
        end)
        has_error(function()
            slsorter:_build_sorted_words({ 3 }, { "what", "about", "deez", "testies" })
        end)
        has_error(function()
            slsorter:_build_sorted_words({ 1, 1, 1, 1, 1, }, { "this", "is", "a", "test" })
        end)
    end)

    it("should respect spaces between words", function()
        local slsorter = SinglelineSorter.new(",")

        equals(
            "this, is,  a,   test",
            slsorter:_build_sorted_words({ 1, 2, 3 }, { "this", "is", "a", "test" })
        )
    end)

    it("should respect non-alphanumeric characters", function()
        local slsorter = SinglelineSorter.new(",")

        equals(
            '"c", "ss", require(\'smartsort\').sort',
            slsorter:_build_sorted_words({ 1, 1 }, { '"c"', '"ss"', "require('smartsort').sort" })
        )
    end)
end)
