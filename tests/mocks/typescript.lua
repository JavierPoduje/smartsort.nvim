local Region = require("region")

--- @class BufferMock
--- @field content string[]
--- @field region Region

local node_with_comment = {
    content = {
        '/**',
        ' * This is a comment',
        ' */',
        "const foo = () => {",
        "  console.log(\"foo\");",
        "};",
    },
    region = Region.new(1, 1, 7, 1),
}

--- @type BufferMock
local simplest = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo\");",
        "};",
        "",
        "function bar() {",
        "  console.log(\"bar\");",
        "}",
    },
    region = Region.new(1, 1, 7, 1),
}

--- @type BufferMock
local with_comment = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo\");",
        "};",
        "",
        "// this is a comment",
        "",
        "function bar() {",
        "  console.log(\"bar\");",
        "}",
    },
    region = Region.new(1, 1, 9, 1),
}

--- @type BufferMock
local with_bigger_gap = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo\");",
        "};",
        "",
        "",
        "",
        "function bar() {",
        "  console.log(\"bar\");",
        "}",
    },
    region = Region.new(1, 1, 9, 1),
}

--- @type BufferMock
local without_gap = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo\");",
        "};",
        "function bar() {",
        "  console.log(\"bar\");",
        "}",
    },
    region = Region.new(1, 1, 6, 1),
}

--- @type BufferMock
local commented_functions = {
    content = {
        '/**',
        ' * This is a comment',
        ' */',
        'const foo = () => {',
        '  console.log("foo");',
        '};',
        '',
        '// this is a comment',
        '',
        '// this comment "belongs" to the function',
        'function bar() {',
        '  console.log("bar");',
        '}',
    },
    region = Region.new(1, 1, 13, 1),
}

return {
    commented_functions = commented_functions,
    node_with_comment = node_with_comment,
    simplest = simplest,
    with_bigger_gap = with_bigger_gap,
    with_comment = with_comment,
    without_gap = without_gap,
}
