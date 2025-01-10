local u = require('utils')

local M = {}

--- @class Coord
--- @field row number: the row of the coord
--- @field col number: the column of the coord

M.setup = function()
end

--- Get the coords of the visual selection
--- @return Coord[]
M.get_selected_lines = function()
    local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

    local start = { row = start_line, col = start_col }
    local finish = { row = end_line, col = end_col }

    assert(start.row <= finish.row, "Start row must be less than or equal to finish row")
    assert(start.col <= finish.col, "Start col must be less than or equal to finish col")

    return { start, finish }
end

return M
