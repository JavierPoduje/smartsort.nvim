local M = {}

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

return M
