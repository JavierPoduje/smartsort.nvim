local Region = require("region")

local simple = {
    content = {
        'M = {}',
        '',
        'M.b = function()',
        '    print("this is b")',
        'end',
        '',
        'M.a = function()',
        '    print("another guy called a")',
        'end',
        '',
        'return M',
    },
    region = Region.new(3, 1, 9, 3),
}

local third = {
    content = {
        'return {',
        '    someValue = "value",',
        '',
        '    anotherValue = { "value1", "value2", }, aaa = "value of aaa",',
        '    aBoolean = true, -- some comment',
        '}',
    },
    region = Region.new(2, 1, 5, 36),
}

local variables = {
    content = {
        'local varC = "something"',
        '',
        '--- @type boolean',
        'local varB = false',
        '--- @type string',
        'local varA = "something"',
    },
    region = Region.new(1, 1, 6, 24),
}

local simple_gap = {
    content = {
        'return {',
        '    aaa = "value of aaa", anotherValue = { "value1", "value2", },',
        '}',
    },
    region = Region.new(2, 1, 2, 65),
}

local no_gap = {
    content = {
        'return {',
        '    aaa = "value of aaa",anotherValue = { "value1", "value2", },',
        '}',
    },
    region = Region.new(2, 1, 2, 65),
}

local module = {
    content = [[
local M = {}

--- Module for various functions
--- @return table
function M:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Prints "something" to the console
--- @return nil
M.printsomething = function(self)
    print("something")
end

--- Returns a string representation of the module
--- @return string
M.__tostring = function(self)
    return "Functions module"
end

return M
    ]],
    region = Region.new(12, 1, 22, 3),
}

return {
    module = module,
    no_gap = no_gap,
    simple = simple,
    simple_gap = simple_gap,
    third = third,
    variables = variables,
}
