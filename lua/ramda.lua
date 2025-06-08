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

return M
