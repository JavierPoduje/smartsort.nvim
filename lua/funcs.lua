local M = {}

--- Check if the column is the max column
---
--- @return boolean
M.is_max_col = function(col)
    return col == vim.v.maxcol
end

--- Returns a sorted list of keys from a table
--- @param tbl table<string, any>
M.sorted_keys = function(tbl)
    local keys = {}
    local idx = 1
    for key in pairs(tbl) do
        keys[idx] = key
        idx = idx + 1
    end
    table.sort(keys)
    return keys
end

M.bool2str = function(bool)
    return bool and "true" or "false"
end

--- Check if a table contains a key
---
--- @param tbl table
--- @param key any
--- @return boolean
M.contains = function(tbl, key)
    return tbl[key] ~= nil
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

M.repeat_str = function(str, times)
    local result = ""
    for _ = 1, times do
        result = result .. str
    end
    return result
end

--- Return the string representation of a node
--- @param node TSNode
--- @return string
M.node_to_string = function(node)
    return vim.treesitter.get_node_text(node, 0)
end

--- @param node TSNode
--- @return string
M.get_function_name = function(node)
    return M.if_else(
        M.contains(node, 1),
        function() return vim.treesitter.get_node_text(node[1], 0) end,
        function() return vim.treesitter.get_node_text(node[3], 0) end
    )
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

--- Get the indent of a line (zero-based)
--- @param bufnr number: the buffer number
--- @param row number: the row to get the indent of
M.get_line_indent = function(bufnr, row)
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    return line:match("^%s*")
end

--- Check if a match is a comment
--- @param matches table<string, TSNode>
--- @return boolean
M.match_is_comment = function(matches)
    return M.contains(matches, 1)
end

return M
