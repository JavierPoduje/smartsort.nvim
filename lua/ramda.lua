local M = {}

--- Placeholder for currying.
M.__ = {}

--- @param predicate (fun(a: any, b: any): boolean): a function that takes two arguments and returns a boolean
--- @return (fun(value: any): fun(table: any[]): boolean): a function that takes a value and returns a function that takes a table
M.any = function(predicate)
    --- @param value any: the value to compare against
    return function(value)
        --- @param table any[]: the table to check
        return function(table)
            for _, v in ipairs(table) do
                if predicate(v)(value) then
                    return true
                end
            end
            return false
        end
    end
end

--- Performs right-to-left function composition.
--- The rightmost function can take multiple arguments; subsequent functions must be unary.
--- @param ... function: A variable number of functions to compose.
--- @return function: A new function that takes arguments for the rightmost function and pipes the result through the preceding functions.
M.compose = function(...)
    local fns = { ... }
    local numFns = #fns

    if numFns == 0 then
        return function(x) return x end
    end

    return function(...)
        local args = { ... }
        local result = fns[numFns](unpack(args))
        for i = numFns - 1, 1, -1 do
            result = fns[i](result)
        end
        return result
    end
end

--- Curries a function.
--- Supports partial application and placeholder (M.__) usage.
--- @param arity number: The number of arguments the function expects.
--- @param func function: The function to curry.
--- @return function: The curried function.
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

--- Returns true if two given values are equal
--- @param a any: the first value to compare
--- @return (fun(b: any): boolean): a function that takes a value and returns a boolean indicating if the two values are equal
M.eq = function(a)
    return function(b)
        return a == b
    end
end

--- @param predicate (fun(value: any, tbl: any[]): boolean): a function that takes a value and returns a boolean
--- @return (fun(table: any[]): any[]): a function that takes a table and returns a new table with only the elements that satisfy the predicate
M.filter = function(predicate)
    return function(tbl)
        local result = {}
        for _, value in ipairs(tbl) do
            if predicate(value, tbl) then
                table.insert(result, value)
            end
        end
        return result
    end
end
-- A unique empty table for distinctness

--- @param fn (fun(value: any, idx: number, tbl: any[]): any): a function that takes a value and returns a new value
--- @return (fun(table: any[]): any[]): a function that takes a table and returns a new table with the function applied to each element
M.map = function(fn)
    --- @param tbl any[]: the table to map
    return function(tbl)
        local result = {}
        for idx, value in ipairs(tbl) do
            result[idx] = fn(value, idx, tbl)
        end
        return result
    end
end

--- Performs left-to-right function composition.
--- The first function can take multiple arguments; subsequent functions must be unary.
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

--- @param fn (fun(acc: any, value: any, idx: number): any): a function that takes an accumulator and a value and returns a new accumulator
--- @return (fun(initial: any): fun(table: any[]): any): a function that takes an initial value and returns a function that takes a table and reduces it to a single value
M.reduce = function(fn)
    --- @param initial any: the initial value for the accumulator
    return function(initial)
        --- @param tbl any[]: the table to reduce
        return function(tbl)
            local acc = initial
            for idx, value in ipairs(tbl) do
                acc = fn(acc, value, idx)
            end
            return acc
        end
    end
end

--- Helper to print tables (for demonstration and debugging)

return M
