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
    local merged = {}
    local tables_to_merge = { ... } -- Collect all arguments into a table

    -- Helper function to copy a table deeply
    local function deep_copy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = deep_copy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end

    -- Iterate through each table provided as an argument
    for _, current_table in ipairs(tables_to_merge) do
        assert(
            type(current_table) == "table",
            "Expected a table, but got " .. type(current_table)
        )

        for k, v in pairs(current_table) do
            if type(v) == "table" and type(merged[k]) == "table" then
                -- Recursive call for nested tables, merging existing with current
                merged[k] = M.merge_tables(merged[k], v)
            elseif type(v) == "table" then
                -- If 'v' is a table but 'merged[k]' is not, deep copy 'v'
                merged[k] = deep_copy(v)
            else
                -- Overwrite with value from the current_table
                merged[k] = v
            end
        end
    end

    return merged
end

--- Returns a merged table containing all elements from the input tables.
--- It does not modify the original tables.
---
--- @param ... table One or more arrays
--- @return table A new table containing all elements from the input tables.
M.merge_arrays = function(...)
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

--- Check if the column is the max column
--- @param col number: the column to check
--- @return boolean
M.is_max_col = function(col)
    return col == vim.v.maxcol
end

--- Returns a string with the given string repeated the specified number of times.
--- @param str string: the string to repeat
--- @param times number: the number of times to repeat the string
--- @return string: the repeated string
M.repeat_str = function(str, times)
    local result = ""
    for _ = 1, times do
        result = result .. str
    end
    return result
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
