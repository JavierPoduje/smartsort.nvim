local Chadnodes = require("chadnodes")
local FileManager = require("file_manager")
local Region = require("region")
local SinglelineSorter = require("singleline_sorter")
local f = require("funcs")
local parsers = require("nvim-treesitter.parsers")

--- @class SmartsortSetup
--- @field non_sortable_behavior? "above" | "below" | "preserve"
--- @field single_line_separator? string

--- @type SmartsortSetup
local smartsort_setup = {
    non_sortable_behavior = "preserve",
    single_line_separator = ",",
}

--- @class Args
--- @field setup? SmartsortSetup: the setup to use for smartsort
--- @field single_line_separator string: the separator to use between words

local M = {}

--- @param input_smartsort_setup SmartsortSetup
M.setup = function(input_smartsort_setup)
    local new_opts = f.merge_tables(smartsort_setup, input_smartsort_setup or {})
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

--- @param inputargs SmartsortSetup: the arguments to use
M.smartsort = function(inputargs)
    local setup = f.merge_tables(smartsort_setup, inputargs or {})
    local region = Region.from_selection()

    if region.srow == region.erow then
        M.sort_single_line(region, setup)
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

M.sort_single_line = function(region, args)
    local raw_str = FileManager.get_line(region)

    --- @type SinglelineSorter
    local singleline_sorter = nil
    local status, err = pcall(function()
        singleline_sorter = SinglelineSorter.new(args.single_line_separator or smartsort_setup.single_line_separator)
    end)
    if not status then
        print(err)
        return
    end

    local sorted_line = singleline_sorter:sort(raw_str)
    FileManager.insert_line_in_buffer(region.srow, region.scol, region.ecol, sorted_line)
end

--- Sort the selected lines
--- @param selected_region Region: the region to sort
--- @param config SmartsortSetup: the configuration to use
M.sort_multiple_lines = function(selected_region, config)
    local parser = parsers.get_parser()

    --- @type Region
    local region = nil
    local status, err = pcall(function()
        region = FileManager.get_region_to_work_with(0, selected_region, parser)
    end)
    if not status then
        print(err)
        return
    end

    --- @type Chadnodes
    local cnodes = nil
    status, err = pcall(function() cnodes = Chadnodes.from_region(0, region, parser) end)
    if not status then
        print(err)
        return
    end

    local linked_cnodes = cnodes:merge_sortable_nodes_with_adjacent_linkable_nodes(region)

    local vertical_gaps = linked_cnodes:calculate_vertical_gaps()
    local horizontal_gaps = linked_cnodes:calculate_horizontal_gaps()
    local should_have_left_indentation_by_idx = linked_cnodes:calculate_left_indentation_by_idx()

    local sorted_nodes_with_gaps = linked_cnodes
        :sort(config)
        :stringify_into_table(
            vertical_gaps,
            horizontal_gaps,
            should_have_left_indentation_by_idx
        )

    FileManager.buf_set_lines(0, region.srow - 1, region.erow, sorted_nodes_with_gaps)
end

return M
