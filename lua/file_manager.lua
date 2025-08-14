local Chadquery = require("chadquery")
local R = require("ramda")
local Region = require("region")
local f = require("funcs")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @alias IndentationType
--- | "spaces"
--- | "tabs"

--- @class FileManager
---
--- @field public region Region
---
--- @field _get_node_indent_type fun(bufnr: number, node: TSNode): IndentationType
--- @field public buf_set_lines fun(bufnr: number, start_row: number, end_row: number, lines: string[])
--- @field public get_line fun(region: Region): string
--- @field public get_node_at_row fun(bufnr: number, row: number, parser: vim.treesitter.LanguageTree, language_queries?: table<string, string>): TSNode
--- @field public get_region_indentation fun(bufnr: number, region: Region): string
--- @field public get_region_to_work_with fun(bufnr: number, selected_region: Region, parser: vim.treesitter.LanguageTree, language_queries?: table<string, string>): Region
--- @field public insert_in_buffer fun(row: number, start_col: number, end_col: number, str: string): FileManager
--- @field public new fun(self: FileManager, bufnr: number, selected_region: Region, parser: vim.treesitter.LanguageTree): FileManager

local FileManager = {}

--- @param bufnr number
--- @param selected_region Region
--- @param parser vim.treesitter.LanguageTree
function FileManager:new(bufnr, selected_region, parser)
    FileManager.__index = FileManager
    local obj = {}
    setmetatable(obj, FileManager)

    obj.region = FileManager.get_region_to_work_with(bufnr, selected_region, parser)

    return obj
end

--- Insert the lines into the buffer in a specific range
---
--- @param bufnr number: the buffer number to insert the string into
--- @param start_row number: the start row to insert the string into
--- @param end_row number: the end row to insert the string into
--- @param lines string[]: the lines to insert
FileManager.buf_set_lines = function(bufnr, start_row, end_row, lines)
    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, true, lines)
end

--- Get the line from the buffer in a specific range
--- @param region Region: the region to get the line from
--- @return string
FileManager.get_line = function(region)
    local full_line = vim.fn.getline(region.srow, region.erow)
    local raw_str = string.sub(full_line[1], region.scol, region.ecol)
    return raw_str
end

--- Returns a new region where everything is exactly the same as the selected region,
--- exept the erow is the smallest value between the parent node's erow and the selected region's
--- erow.
--- @param bufnr number
--- @param selected_region Region
--- @param parser vim.treesitter.LanguageTree
--- @param language_queries? table<string, string>
--- @return Region
FileManager.get_region_to_work_with = function(bufnr, selected_region, parser, language_queries)
    local node = FileManager.get_node_at_row(bufnr, selected_region, parser, language_queries)
    if node == nil then
        vim.notify("No supported node was found in the first line selected", vim.log.levels.WARN)
        error()
    end

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    local parent_region = Region.from_node(parent)

    local srow = selected_region.srow
    local scol = selected_region.scol
    local erow = math.min(selected_region.erow, parent_region.erow + 1)
    local ecol = selected_region.ecol
    return Region.new(srow, scol, erow, ecol)
end

--- Get the node at the given row
--- @param bufnr number
--- @param region Region
--- @param parser vim.treesitter.LanguageTree
--- @param language_queries? table<string, string>
--- @return TSNode | nil
FileManager.get_node_at_row = function(bufnr, region, parser, language_queries)
    language_queries = language_queries or {}

    local row = region.srow
    local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    if #lines == 0 then
        return nil
    end

    local chadquery = Chadquery:new(
        parser:lang(),
        { region = region, root_node = parser:parse()[1]:root() },
        language_queries
    )

    local first_line = lines[1]
    local first_non_empty_char = first_line:find("%S") or 1

    -- Save cursor position
    local saved_cursor = vim.api.nvim_win_get_cursor(0)

    -- Move cursor to the position we want to check
    vim.api.nvim_win_set_cursor(0, { row, first_non_empty_char - 1 })

    -- Get the node at cursor (most indented node) and walk up the tree to find a suitable block node
    local block_types = chadquery:sort_and_linkable_nodes()
    local node_at_cursor = ts_utils.get_node_at_cursor(0, false)
    while node_at_cursor ~= nil and not R.any(R.equals(node_at_cursor:type()), block_types) do
        node_at_cursor = node_at_cursor:parent()
    end

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(0, saved_cursor)

    return node_at_cursor
end

--- Insert the string into the buffer in a single line in a specific range
---
--- @param row number: the row to insert the string into
--- @param start_col number: the start column to insert the string into
--- @param end_col number: the end column to insert the string into
--- @param str string: the string to insert
FileManager.insert_line_in_buffer = function(row, start_col, end_col, str)
    if f.is_max_col(end_col) then
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
        end_col = #line
    end
    vim.api.nvim_buf_set_text(0, row - 1, start_col - 1, row - 1, end_col, { str })
end

--- Get the indentation of the leftmost line in a given region.
--- Counts spaces and tabs, where each tab is equivalent to 1 space.
--- @param bufnr number: the buffer number
--- @param region Region The region to analyze
--- @return string
FileManager.get_region_indentation = function(bufnr, region)
    assert(region ~= nil, "Region cannot be nil")

    local output = ""

    -- Get all lines in the region (srow and erow are 1-based, Neovim API is 0-based)
    local lines = vim.api.nvim_buf_get_lines(bufnr, region.srow, region.erow + 1, false)
    if not lines or #lines == 0 then
        return output
    end

    -- Initialize min_indent to a large number
    local min_indent = math.huge

    -- Iterate through each line to find the minimum indentation
    for _, line in ipairs(lines) do
        local line_indentation = ""
        local indent = 0
        for char in line:gmatch(".") do
            if char == " " then
                indent = indent + 1
                line_indentation = line_indentation .. " "
            elseif char == "\t" then
                indent = indent + 1
                line_indentation = line_indentation .. "\t"
            else
                break
            end
        end

        -- Update min_indent if this line's indentation is smaller and the line is not empty
        if indent < min_indent and line:match("%S") then
            min_indent = indent
            output = line_indentation
        end
    end

    return output
end

--- Determine the indentation type ("spaces" or "tabs") of the first indented line in a TSNode's text.
--- Returns "spaces" if no indentation is found.
--- @param bufnr number
--- @param node TSNode
--- @return IndentationType
FileManager._get_node_indent_type = function(bufnr, node)
    bufnr = bufnr or 0
    assert(node ~= nil, "Node cannot be nil")

    -- Get the text of the node
    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = {} })
    if not text then
        return "spaces" -- Return default if no text
    end

    -- Convert text to lines if it's a string
    local lines = type(text) == "string" and vim.split(text, "\n", { trimempty = false }) or text

    assert(type(lines) == "table", "Expected lines to be a table")
    assert(#lines > 0, "Expected lines to have at least one element")

    -- Check each line for indentation
    for _, line in ipairs(lines) do
        if line:match("^%s+") then -- Check if line starts with whitespace
            local first_char = line:match("^(%s)")
            if first_char == "\t" then
                return "tabs"
            elseif first_char == " " then
                return "spaces"
            end
        end
    end

    -- Return "spaces" if no indentation is found
    return "spaces"
end

return FileManager
