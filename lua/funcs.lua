local M = {}

--- Print the value of a variable
M.debug = function(arg)
    print(vim.inspect(arg))
end

--- Check if the column is the max column
--- @return boolean
M.is_max_col = function(col)
    return col == vim.v.maxcol
end

M.bool2str = function(bool)
    return bool and "true" or "false"
end

return M
