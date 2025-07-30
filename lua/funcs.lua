local R = require "ramda"

local M = {}

--- Get the indent of a line (zero-based)
--- @param bufnr number: the buffer number
--- @param row number: the row to get the indent of
M.get_line_indent = function(bufnr, row)
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    return line:match("^%s*")
end

--- Given a predicate, returns the result of either `if_true` or `if_false` callbacks.
--- @param predicate boolean
--- @param if_true fun(): any
--- @param if_false fun(): any
--- @return any
M.if_else = function(predicate, if_true, if_false)
    if predicate then
        return if_true()
    else
        return if_false()
    end
end

--- Check if the column is the max column
--- @param col number: the column to check
--- @return boolean
M.is_max_col = function(col)
    return col == vim.v.maxcol
end

--- Returns a merged table containing all elements from the input tables.
--- It does not modify the original tables.
---
--- @param ... table One or more arrays
--- @return table A new table containing all elements from the input tables.
M.merge_arrays = function(...)
    return R.reduce(function(output, current_table)
        assert(current_table ~= nil, "Expected a table, got nil")
        assert(type(current_table) == "table", "Expected a table, got " .. type(current_table))
        return R.reduce(function(acc, node)
            table.insert(acc, node)
            return acc
        end, output, current_table)
    end, {}, { ... })
end

--- Returns a merged table containing all elements from the input tables.
--- It does not modify the original tables.
---
--- @param ... table One or more tables to merge.
--- @return table A new table containing all elements from the input tables.
M.merge_tables = function(...)
    return R.reduce(function(merged, current_table)
        assert(
            type(current_table) == "table",
            "Expected a table, but got " .. type(current_table)
        )
        return vim.tbl_deep_extend("force", merged, current_table)
    end, {}, { ... })
end

--- Return the string representation of a node
--- @param node TSNode
--- @return string
M.node_to_string = function(node)
    return vim.treesitter.get_node_text(node, 0)
end

--- Get the trimmed string
---
--- @param str string: the string to trim
--- @return string: the trimmed string
M.trim = function(str)
    local trimmed_str = string.match(str, "^%s*(.-)%s*$")
    return trimmed_str
end

--- Replace the last item in a table with a new value.
--- If the table is empty, it does nothing.
--- @param tbl table: the table to modify
--- @param value any: the value to replace the last item with
--- @return table
M.replace_last_item = function(tbl, value)
    local new_tbl = vim.deepcopy(tbl)
    if #new_tbl == 0 then
        return new_tbl
    end
    new_tbl[#new_tbl] = value
    return new_tbl
end

return M
