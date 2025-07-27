local Chadnodes = require("chadnodes")
local FileManager = require("file_manager")
local R = require("ramda")
local Region = require("region")
local f = require("funcs")
local parsers = require("nvim-treesitter.parsers")

--- @class SmartsortSetup
--- @field non_sortable_behavior "above" | "below" | "preserve"

--- @type SmartsortSetup
local smartsort_setup = {
    non_sortable_behavior = "preserve",
}

--- @class Args
--- @field separator string: the separator to use between words
--- @field setup? SmartsortSetup: the setup to use for smartsort

local M = {
    separator = ",",
}

-- TODO: use this later, when configuration is implemented
M.setup = function(opts)
    local new_opts = f.merge_tables(smartsort_setup, opts or {})
    smartsort_setup = f.merge_tables(smartsort_setup, new_opts)
end

M.print_chadnodes = function()
    local parser = parsers.get_parser()
    local region = FileManager.get_region_to_work_with(0, Region.from_selection(), parser)
    local cnodes = Chadnodes.from_region(0, region, parser)

    for _, cnode in ipairs(cnodes.nodes) do
        print(cnode:__tostring())
    end
end

--- @param inputargs Args: the arguments to use
M.smartsort = function(inputargs)
    local args = inputargs or {}
    local setup = f.merge_tables(
        smartsort_setup,
        args.setup or {}
    )

    local region = Region.from_selection()

    if region.srow == region.erow then
        M.sort_single_line(region, args)
    else
        M.sort_multiple_lines(region, setup)
    end
end

--- Sort the selected text
--- @param args Args: the arguments to use
M.sort = function(args)
    local region = Region.from_selection()
    local setup = f.merge_tables(
        smartsort_setup,
        args.setup or {}
    )

    if region.srow == region.erow then
        M.sort_single_line(region, args)
    else
        M.sort_multiple_lines(region, setup)
    end
end

--- Print the selected region
M.region = function()
    print(Region.from_selection())
end

--- Sort the selected line
--- @param region Region: the region to sort
--- @param args Args: the arguments to use
M.sort_single_line = function(region, args)
    if args.separator == nil then
        print("Separator is required")
        return
    end

    assert(args.separator ~= nil, "Separator is required")

    local separator = args.separator
    local full_line = vim.fn.getline(region.srow, region.erow)
    local raw_str = string.sub(full_line[1], region.scol, region.ecol)
    local final_char_is_separator = false

    local trimmed_str, leftpad, rightpad = M._trim(raw_str)
    if string.sub(trimmed_str, -1) == separator then
        trimmed_str = string.sub(trimmed_str, 1, -2)
        final_char_is_separator = true
    end
    local spaces_between_words = M._calculate_spaces_between_words(trimmed_str, separator)

    -- split words by separator
    local words = vim.fn.split(trimmed_str, separator .. "\\s*")

    table.sort(words)

    local str_to_insert = table.concat({
        leftpad,
        M._build_sorted_words(spaces_between_words, words, separator),
        final_char_is_separator and separator or "",
        rightpad,
    }, "")

    FileManager.insert_line_in_buffer(region.srow, region.scol, region.ecol, str_to_insert)
end

--- Sort the selected lines
--- @param selected_region Region: the region to sort
--- @param config SmartsortSetup: the configuration to use
M.sort_multiple_lines = function(selected_region, config)
    local parser = parsers.get_parser()
    local region = FileManager.get_region_to_work_with(0, selected_region, parser)
    local cnodes = Chadnodes.from_region(0, region, parser)

    local linked_cnodes = cnodes:merge_sortable_nodes_with_adjacent_linkable_nodes(region)
    local vertical_gaps = cnodes:calculate_vertical_gaps()
    local horizontal_gaps = cnodes:calculate_horizontal_gaps()
    local should_have_left_padding_by_idx = linked_cnodes:calculate_left_padding_by_idx()

    local sorted_nodes_with_gaps = linked_cnodes
        :sort(config)
        :stringify_into_table(
            vertical_gaps,
            horizontal_gaps,
            should_have_left_padding_by_idx)
    vim.api.nvim_buf_set_lines(0, region.srow - 1, region.erow, true, sorted_nodes_with_gaps)
end

--- Build the string of sorted words
---
--- @param spaces_between_words number[]: the spaces between words
--- @param words string[]: the words to build the sorted words of
--- @param separator string: the separator to use between words
--- @return string: the sorted words
M._build_sorted_words = function(spaces_between_words, words, separator)
    assert(
        #words == #spaces_between_words + 1,
        "Number of spaces between words must be one less than the number of words"
    )

    local output = R.reduce(function(acc, word, idx)
        table.insert(acc, word)

        -- add comma at the end of word if it's not the last word
        if idx < #words then
            table.insert(acc, separator)
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

--- Calculate the spaces between. The spaces are only calculated between words separated by a comma.
---
--- @param str string: the string to calculate the spaces between words of
--- @param separator string: the separator to use between words
--- @return number[]: the spaces between words
M._calculate_spaces_between_words = function(str, separator)
    if #str <= 1 then
        return {}
    end

    --- @type number[]
    local spaces = {}
    local idx = 1
    local count_spaces = false

    while idx <= #str do
        if string.sub(str, idx, idx) == separator then
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
