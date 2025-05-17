local M = {}

--- Check if a table contains a key
---
--- @param tbl table
--- @param key any
--- @return boolean
M.contains = function(tbl, key)
    return tbl[key] ~= nil
end


--- Returns a merged table containing all elements from the input tables.
--- It does not modify the original tables.
---
--- @param ... table One or more tables to merge.
--- @return table A new table containing all elements from the input tables.
M.merge_tables = function(...)
    local args = { ... }
    local output = {}
    for _, current_table in ipairs(args) do
        assert(current_table ~= nil, "Expected a table, got nil")
        assert(type(current_table) == "table", "Expected a table, got " .. type(current_table))

        for _, node in ipairs(current_table) do
            table.insert(output, node)
        end
    end
    return output
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

--- Return the string representation of a node
--- @param node TSNode
--- @return string
M.node_to_string = function(node)
    return vim.treesitter.get_node_text(node, 0)
end

--- Get the indent of a line (zero-based)
--- @param bufnr number: the buffer number
--- @param row number: the row to get the indent of
M.get_line_indent = function(bufnr, row)
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    return line:match("^%s*")
end

return M
