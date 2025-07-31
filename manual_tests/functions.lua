local M = {}

--- Module for various functions
--- @return table
function M:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Returns a string representation of the module
--- @return string
M.__tostring = function(self)
    return "Functions module"
end

--- Prints "something" to the console
--- @return nil
M.printsomething = function(self)
    print("something")
end

return M
