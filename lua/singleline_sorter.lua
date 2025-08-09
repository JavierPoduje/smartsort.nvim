local FileManager = require("file_manager")
local R = require("ramda")

--- @class SinglelineSorter
---
--- @field separator string: the separator to use between words
---
--- @field _build_sorted_words fun(self: SinglelineSorter, spaces_between_words: number[], words: string[]): string
--- @field _is_inside_string fun(self: SinglelineSorter, str: string): boolean
--- @field _split_ignoring_strings_with_spaces fun(self: SinglelineSorter, str: string): string[], number[]
--- @field _trim fun(str: string): string, string, string
--- @field new fun(separator: string): SinglelineSorter
--- @field sort fun(self: SinglelineSorter, raw_str: string): string

local SinglelineSorter = {}

--- Build the string of sorted words
--- @param self SinglelineSorter
--- @param spaces_between_words number[]: the spaces between words
--- @param words string[]: the words to build the sorted words of
--- @return string: the sorted words
SinglelineSorter._build_sorted_words = function(self, spaces_between_words, words)
    assert(
        #words == #spaces_between_words + 1,
        "Number of spaces between words must be one less than the number of words"
    )

    local output = R.reduce(function(acc, word, idx)
        table.insert(acc, word)

        -- add comma at the end of word if it's not the last word
        if idx < #words then
            table.insert(acc, self.separator)
        end

        -- add next gap if needed
        if idx < #words then
            local gap = string.rep(" ", spaces_between_words[idx])
            table.insert(acc, gap)
        end

        return acc
    end, {}, words)

    return table.concat(output, "")
end

--- Check if a character position is inside a string literal
--- @param str string: the string to check
--- @param pos number: the position in the string (1-indexed)
--- @return boolean: true if the position is inside a string literal
SinglelineSorter._is_inside_string = function(str, pos)
    local i = 1
    local in_string = false
    local quote_char = nil

    while i <= pos do
        local char = string.sub(str, i, i)

        if char == "'" or char == '"' then
            if not in_string then
                -- Start of string
                in_string = true
                quote_char = char
            elseif quote_char == char then
                -- End of string (only if it's the same quote type)
                in_string = false
                quote_char = nil
            end
        elseif char == "\\" and in_string then
            -- Skip escaped character
            i = i + 1
        end

        i = i + 1
    end

    return in_string
end

--- Split string by separator, ignoring separators inside string literals, and calculate spaces
--- @param self SinglelineSorter
--- @param str string: the string to split
--- @return string[], number[]: array of split parts and spaces between them
SinglelineSorter._split_ignoring_strings_with_spaces = function(self, str)
    local parts = {}
    local spaces = {}
    local current_part = ""
    local i = 1

    while i <= #str do
        local char = string.sub(str, i, i)

        if char == self.separator and not SinglelineSorter._is_inside_string(str, i) then
            -- Found separator outside of string
            table.insert(parts, current_part)
            current_part = ""

            -- Calculate spaces after this separator
            local space_count = 0
            i = i + 1
            while i <= #str and string.sub(str, i, i) == " " do
                space_count = space_count + 1
                i = i + 1
            end
            table.insert(spaces, space_count)
        else
            current_part = current_part .. char
            i = i + 1
        end
    end

    -- Add the last part
    table.insert(parts, current_part)

    return parts, spaces
end

--- Get the trimmed string, and the left and right "padding", where padding is the empty space
--- before and after the string.
--- @param str string: the string to get the padding of
--- @return string, string, string: the trimmed given string, the left padding as empty space, the right padding as empty space
SinglelineSorter._trim = function(str)
    local leftpad = string.match(str, "^%s*")
    local rightpad = string.match(str, "%s*$")
    local trimmed_str = string.match(str, "^%s*(.-)%s*$")
    return trimmed_str, leftpad, rightpad
end

SinglelineSorter.new = function(separator)
    if separator == nil then
        error("Separator is required")
    end

    SinglelineSorter.__index = SinglelineSorter
    local obj = {}
    setmetatable(obj, SinglelineSorter)

    obj.separator = separator

    return obj
end

--- Sort the selected line. It modifies the buffer directly.
--- @param self SinglelineSorter
--- @param raw_str string: the line to sort
--- @return string: the sorted line
SinglelineSorter.sort = function(self, raw_str)
    local final_char_is_separator = false
    local trimmed_str, leftpad, rightpad = SinglelineSorter._trim(raw_str)
    if string.sub(trimmed_str, -1) == self.separator then
        trimmed_str = string.sub(trimmed_str, 1, -2)
        final_char_is_separator = true
    end
    -- split words by separator, ignoring separators inside strings, and calculate spaces
    local words, spaces_between_words = self:_split_ignoring_strings_with_spaces(trimmed_str)

    table.sort(words)

    local str_to_insert = table.concat({
        leftpad,
        self:_build_sorted_words(spaces_between_words, words),
        final_char_is_separator and self.separator or "",
        rightpad,
    }, "")

    return str_to_insert
end

return SinglelineSorter
