local M = {}

M.__ = {} -- A unique empty table for distinctness

--- Checks if at least one element in a list satisfies a predicate.
--- @param predicate function: (value, index, list) -> boolean
--- @param list table: The list to check.
--- @return boolean: True if any element satisfies the predicate, false otherwise.
local _any = function(predicate, list)
    if type(list) ~= "table" then
        error("M.any expects a table as the list argument.", 2)
    end

    for idx, value in ipairs(list) do
        if predicate(value, idx, list) then
            return true
        end
    end
    return false
end

--- Performs a deep equality comparison between two values.
--- Handles tables (lists and dictionaries) recursively.
---
--- @param a any: The first value.
--- @param b any: The second value.
--- @return boolean: True if the values are deeply equal, false otherwise.
local _equals
_equals = function(a, b)
    -- If types are different, they can't be equal
    if type(a) ~= type(b) then
        return false
    end

    -- If they are the same reference (for tables) or same value (for primitives)
    if a == b then
        return true
    end

    -- If not tables, and not `a == b` (already handled), then they are not equal
    if type(a) ~= "table" then
        return false
    end

    -- Handle tables (lists and dictionaries)
    -- Check if keys (and values) are the same
    local visited = {} -- To prevent infinite loops with circular references

    local function compareTables(t1, t2)
        if visited[t1] == t2 and visited[t2] == t1 then -- Already visited and matched
            return true
        end
        visited[t1] = t2
        visited[t2] = t1

        -- Check number of elements / keys (for arrays and dictionaries)
        if #t1 ~= #t2 then -- For array-like tables
            return false
        end

        local keys1 = {}
        for k in pairs(t1) do
            table.insert(keys1, k)
        end
        local keys2 = {}
        for k in pairs(t2) do
            table.insert(keys2, k)
        end

        if #keys1 ~= #keys2 then -- For dictionary-like tables (number of keys)
            return false
        end

        -- Check values for array-like part (ipairs for numeric indices)
        for i = 1, #t1 do
            --- @diagnostic disable-next-line: undefined-global
            if not _equals(t1[i], t2[i]) then
                return false
            end
        end

        -- Check key-value pairs for dictionary-like part (pairs for all keys)
        for k, v1 in pairs(t1) do
            if type(k) == "number" and k >= 1 and k <= #t1 then
                -- Already checked by ipairs
            else
                local v2 = t2[k]
                --- @diagnostic disable-next-line: undefined-global
                if not _equals(v1, v2) then
                    return false
                end
            end
        end

        -- Check if t2 has keys that t1 does not
        for k, v2 in pairs(t2) do
            if type(k) == "number" and k >= 1 and k <= #t2 then
                -- Already checked by ipairs
            else
                if t1[k] == nil and v2 ~= nil then -- Key exists in t2 but not t1 (and not nil in t2)
                    return false
                end
            end
        end

        return true
    end

    return compareTables(a, b)
end

--- Filters elements from a list based on a predicate function.
--- @generic T
--- @param predicate fun(value: T, idx: number, list: T[]): boolean
--- @param list T[]: The list to filter.
--- @return T[]
local _filter = function(predicate, list)
    if type(list) ~= "table" then
        error("M.filter expects a table as the list argument.", 2)
    end

    local result = {}
    for idx, value in ipairs(list) do
        if predicate(value, idx, list) then
            table.insert(result, value)
        end
    end
    return result
end

--- Gets the last item from a given table or the last character from a string.
--- @param list table|string: The list to get the last item from.
--- @return any: The last item, or nil if the list is empty.
local _last = function(list)
    if type(list) == "table" then
        return list[#list]
    end

    if type(list) == "string" then
        return string.sub(list, -1)
    end

    return nil
end

--- Helper to print tables (for demonstration and debugging)
M._inspect = function(t, indent)
    indent = indent or ""
    local str = "{"
    local first = true
    for k, v in pairs(t) do
        if not first then
            str = str .. ", "
        end
        first = false
        if type(k) == "string" then
            str = str .. k .. "="
        end
        if type(v) == "table" then
            if v == M.__ then
                str = str .. "__"
            else
                str = str .. M._inspect(v, indent .. "  ")
            end
        elseif type(v) == "string" then
            str = str .. string.format("%q", v)
        else
            str = str .. tostring(v)
        end
    end
    str = str .. "}"
    return str
end

--- Transforms each element of a list using a mapper function.
--- @param mapper function: (value, index, list) -> newValue
--- @param list table: The list to map over.
--- @return table: A new list with transformed elements.
local _map = function(mapper, list)
    if type(list) ~= "table" then
        error("M.map expects a table as the list argument.", 2)
    end

    local result = {}
    for idx, value in ipairs(list) do
        table.insert(result, mapper(value, idx, list))
    end
    return result
end

--- Retrieves the value of a property from a table.
--- If the property does not exist, returns nil.
---
--- @param p string | number: The name of the property to retrieve.
--- @param obj table: The table from which to retrieve the property.
--- @return any: The value of the property, or nil if not found.
local _prop = function(p, obj)
    if type(obj) ~= "table" then
        return nil
    end
    return obj[p]
end

--- Reduces a list to a single value by applying a reducer function.
--- This version is designed to be curried with an arity of 3:
--- (reducer, initialValue, list).
---
--- @param reducer function: (accumulator, currentValue, index, list) -> newAccumulator
--- @param initialValue any: The starting value for the accumulator.
--- @param list table: The list to iterate over.
--- @return any: The reduced value.
local _reduce = function(reducer, initialValue, list)
    if type(list) ~= "table" then
        error("reduce expects a table as the list argument.", 2)
    end

    local acc = initialValue
    for idx, value in ipairs(list) do
        acc = reducer(acc, value, idx, list)
    end
    return acc
end

--- Curries a function.
--- Supports partial application and placeholder (M.__) usage.
---
--- @param arity number The number of arguments the function expects.
--- @param func fun(...: any): any The function to curry.
--- @return fun(...: any): any The curried function.
M.curry = function(arity, func)
    if type(arity) ~= "number" or arity < 0 then
        error("curry: arity must be a non-negative number", 2)
    end
    if type(func) ~= "function" then
        error("curry: func must be a function", 2)
    end

    local function curried(collectedArgs)
        return function(...)
            local newArgs = { ... }
            local filledArgs = {}

            local newArgIndex = 1
            for i = 1, arity do
                if collectedArgs[i] == M.__ and newArgs[newArgIndex] ~= nil then
                    filledArgs[i] = newArgs[newArgIndex]
                    newArgIndex = newArgIndex + 1
                elseif collectedArgs[i] ~= nil then
                    filledArgs[i] = collectedArgs[i]
                elseif newArgs[newArgIndex] ~= nil then
                    filledArgs[i] = newArgs[newArgIndex]
                    newArgIndex = newArgIndex + 1
                else
                    filledArgs[i] = M.__
                end
            end

            local actualArgs = {}
            local argsCount = 0
            for i = 1, arity do
                if filledArgs[i] ~= M.__ then
                    argsCount = argsCount + 1
                    actualArgs[argsCount] = filledArgs[i]
                end
            end

            if argsCount >= arity then
                return func(unpack(actualArgs))
            else
                return curried(filledArgs)
            end
        end
    end

    return curried({})
end

---- Performs left-to-right function composition.
--- The first function can take multiple arguments; subsequent functions must be unary.
---
--- @param ... function: A variable number of functions to compose.
--- @return function: A new function that takes arguments for the first function and pipes the result through the subsequent functions.
M.pipe = function(...)
    local fns = { ... }
    if #fns == 0 then
        return function(x) return x end
    end

    return function(...)
        local args = { ... }
        local result = fns[1](unpack(args))
        for i = 2, #fns do
            result = fns[i](result)
        end
        return result
    end
end

--- Checks if at least one element in a list satisfies a predicate.
--- Curried.
M.any = M.curry(2, _any)

--- Performs a deep equality check between two values.
--- Curried.
M.equals = M.curry(2, _equals)

--- Filters elements from a list based on a predicate.
--- Curried.
M.filter = M.curry(2, _filter)

--- Gets the last item from a given table or string. Returns nil if the table is empty.
--- Curried.
M.last = M.curry(1, _last)

--- Transforms each element of a list using a mapper function.
--- Curried.
M.map = M.curry(2, _map)

--- Retrieves the value of a property from a table.
--- Curried.
M.prop = M.curry(2, _prop)

--- Performs left-to-right function composition.
--- Curried.
M.reduce = M.curry(3, _reduce)

return M
