local M = {}

--- Print the value of a variable
local debug = function(arg)
    print(vim.inspect(arg))
end

--- Check if the column is the max column
--- @return boolean
local is_max_col = function(col)
    return col == vim.v.maxcol
end

return M {
    debug = debug,
    is_max_col = is_max_col
}
