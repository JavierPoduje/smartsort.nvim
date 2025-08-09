local Chadquery = require("chadquery")
local R = require("ramda")
local Region = require("region")
local f = require("funcs")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class FileManager
---
--- @field public region Region
---
--- @field public buf_set_lines fun(bufnr: number, start_row: number, end_row: number, lines: string[])
--- @field public get_line fun(region: Region): string
--- @field public get_node_at_row fun(bufnr: number, row: number, parser: vim.treesitter.LanguageTree): TSNode
--- @field public get_region_to_work_with fun(bufnr: number, selected_region: Region, parser: vim.treesitter.LanguageTree): Region
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
    vim.api.nvim_buf_set_lines(0, start_row, end_row, true, lines)
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
--- @return Region
FileManager.get_region_to_work_with = function(bufnr, selected_region, parser)
    local node = FileManager.get_node_at_row(bufnr, selected_region, parser)
    if node == nil then
        error("No node found at the given selected region")
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
--- @return TSNode | nil
FileManager.get_node_at_row = function(bufnr, region, parser)
    local row = region.srow
    local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    if #lines == 0 then
        return nil
    end

    local chadquery = Chadquery:new(parser:lang(), {
        region = region,
        root_node = parser:parse()[1]:root(),
    })

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

return FileManager
