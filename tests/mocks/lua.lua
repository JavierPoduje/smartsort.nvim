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

return {
    simple = simple,
    third = third,
    variables = variables,
}
