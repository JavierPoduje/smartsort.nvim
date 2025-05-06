local M = {}

--- Check if a table contains a key
---
--- @param tbl table
--- @param key any
--- @return boolean
M.contains = function(tbl, key)
    return tbl[key] ~= nil
end

--- Get the indent of a line (zero-based)
--- @param bufnr number: the buffer number
--- @param row number: the row to get the indent of
M.get_line_indent = function(bufnr, row)
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    return line:match("^%s*")
end

--- @param node TSNode
--- @return TSNode
M.get_node = function(node)
    return M.if_else(
        M.contains(node, 2),
        function() return node[2] end,
        function() return node[4] end
    )
end

--- Given a predicate, return the first value if true, else the second value
--- @param predicate boolean
--- @param if_true function<any>
--- @param if_false function<any>
--- @return any
M.if_else = function(predicate, if_true, if_false)
    if predicate then
        return if_true()
    else
        return if_false()
    end
end

--- Check if the column is the max column
---
--- @return boolean
M.is_max_col = function(col)
    return col == vim.v.maxcol
end

M.is_special_end_char = function(ch)
    local end_chars = { ";" }
    for _, end_char in ipairs(end_chars) do
        if ch == end_char then
            return true
        end
    end
    return false
end

return M
