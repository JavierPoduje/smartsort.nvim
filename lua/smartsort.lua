local f = require("funcs")
-- local parsers = require("nvim-treesitter.parsers")

local M = {}

--- @class Selection
--- @field start Coord: the start of the selection
--- @field finish Coord: the end of the selection

--- @class SmartSort
--- @field selection Selection: the selected scope to sort

--- @class Coord
--- @field row number: the row of the coord
--- @field col number: the column of the coord

M.setup = function() end

M.sort = function()
    local coords = M.selection_coords()
    if coords.start.row == coords.finish.row then
        M.sort_single_line(coords)
    else
        M.sort_lines(coords)
    end
end

--- Sort the selected lines
---
--- @param coords Selection: the selection to sort
M.sort_lines = function(coords)
    -- local parser = parsers.get_parser()
    -- local tree = parser:parse()[1]
    -- local root = tree:root()

    f.debug(coords)
    print("sort several lines")
end

--- Sort the selected line
---
--- @param coords Selection: the selection to sort
M.sort_single_line = function(coords)
    local full_line = vim.fn.getline(coords.start.row, coords.finish.row)
    local raw_str = string.sub(full_line[1], coords.start.col, coords.finish.col)

    local trimmed_str, leftpad, rightpad = M._trim(raw_str)
    local spaces_between_words = M._calculate_spaces_between_words(trimmed_str)

    -- split words by comma
    local words = vim.fn.split(trimmed_str, ",\\s*")

    table.sort(words)

    local str_to_insert = table.concat({
        leftpad,
        M._build_sorted_words(spaces_between_words, words),
        rightpad,
    }, "")

    M._insert_in_buffer(coords.start.row, coords.start.col, coords.finish.col, str_to_insert)
end

--- Get the coords of the visual selection
---
--- @return Selection
M.selection_coords = function()
    local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

    local start = { row = start_line, col = start_col }
    local finish = { row = end_line, col = end_col }

    assert(start.row <= finish.row, "Start row must be less than or equal to finish row")
    assert(start.col <= finish.col, "Start col must be less than or equal to finish col")

    return { start = start, finish = finish }
end


--- Insert the string into the buffer in a single line in a specific range
---
--- @param row number: the row to insert the string into
--- @param start_col number: the start column to insert the string into
--- @param end_col number: the end column to insert the string into
--- @param str string: the string to insert
--- @return nil
M._insert_in_buffer = function(row, start_col, end_col, str)
    if f.is_max_col(end_col) then
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
        end_col = #line
    end
    vim.api.nvim_buf_set_text(0, row - 1, start_col - 1, row - 1, end_col, { str })
end

--- Build the string of sorted words
---
--- @param spaces_between_words number[]: the spaces between words
--- @param words string[]: the words to build the sorted words of
--- @return string: the sorted words
---
M._build_sorted_words = function(spaces_between_words, words)
    assert(
        #words == #spaces_between_words + 1,
        "Number of spaces between words must be one less than the number of words"
    )

    local output = {}

    for i, word in ipairs(words) do
        table.insert(output, word)

        -- add comma at the end of word if it's not the last word
        if i < #words then
            table.insert(output, ",")
        end

        -- add next gap if needed
        if i < #words then
            local gap = string.rep(" ", spaces_between_words[i])
            table.insert(output, gap)
        end
    end

    return table.concat(output, "")
end

--- Calculate the spaces between. The spaces are only calculated between words separated by a comma.
---
--- @param str string: the string to calculate the spaces between words of
--- @return number[]: the spaces between words
M._calculate_spaces_between_words = function(str)
    if #str <= 1 then
        return {}
    end

    --- @type number[]
    local spaces = {}
    local idx = 1
    local count_spaces = false

    while idx <= #str do
        if string.sub(str, idx, idx) == "," then
            idx = idx + 1
            count_spaces = true
        end

        if count_spaces and string.sub(str, idx, idx) == " " then
            local space_idx = idx
            while string.sub(str, space_idx, space_idx) == " " do
                space_idx = space_idx + 1
            end
            local number_of_spaces = space_idx - idx
            table.insert(spaces, number_of_spaces)

            idx = space_idx
            count_spaces = false
        elseif count_spaces and string.sub(str, idx, idx) ~= " " then
            table.insert(spaces, 0)
            idx = idx + 1
            count_spaces = false
        else
            idx = idx + 1
        end
    end
    return spaces
end

--- Get the trimmed string, and the left and right "padding", where padding is the empty space
--- before and after the string.
---
--- @param str string: the string to get the padding of
--- @return string, string, string: the trimmed given string, the left padding as empty space, the right padding as empty space
M._trim = function(str)
    local leftpad = string.match(str, "^%s*")
    local rightpad = string.match(str, "%s*$")
    local trimmed_str = string.match(str, "^%s*(.-)%s*$")
    return trimmed_str, leftpad, rightpad
end

return M
