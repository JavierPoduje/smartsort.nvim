local Chadquery = require("chadquery")
local R = require("ramda")
local Region = require("region")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class FileManager
---
--- @field public region Region
---
--- @field public get_node_at_row fun(bufnr: number, row: number, parser: vim.treesitter.LanguageTree): TSNode
--- @field public new fun(self: FileManager, bufnr: number, selected_region: Region, parser vim.treesitter.LanguageTree): FileManager
--- @field public get_region_to_work_with fun(bufnr: number, selected_region: Region, parser: vim.treesitter.LanguageTree): Region

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

--- Returns a new region where everything is exactly the same as the selected region,
--- exept the erow is the smallest value between the parent node's erow and the selected region's
--- erow.
---
--- @param bufnr number
--- @param selected_region Region
--- @param parser vim.treesitter.LanguageTree
FileManager.get_region_to_work_with = function(bufnr, selected_region, parser)
    local node = FileManager.get_node_at_row(bufnr, selected_region, parser)
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    local parent_region = Region.from_node(parent)

    --- return the selected region where the erow will be the smallest value between the
    --- parent_region's erow and the selected region's erow
    return Region.new(selected_region.srow, selected_region.scol, math.min(selected_region.erow, parent_region.erow), selected_region.ecol)
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

return FileManager
