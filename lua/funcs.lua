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

return M
