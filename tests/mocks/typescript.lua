local Region = require("region")

--- @class BufferMock
--- @field content string[]
--- @field region Region

--- @type BufferMock
local simplest = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo \");",
        "};",
        "",
        "function bar() {",
        "  console.log(\"bar \");",
        "}",
    },
    region = Region.new(1, 1, 7, 1),
}

--- @type BufferMock
local with_comment = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo \");",
        "};",
        "",
        "// this is a comment",
        "",
        "function bar() {",
        "  console.log(\"bar \");",
        "}",
    },
    region = Region.new(1, 1, 9, 1),
}

--- @type BufferMock
local with_bigger_gap = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo \");",
        "};",
        "",
        "",
        "",
        "function bar() {",
        "  console.log(\"bar \");",
        "}",
    },
    region = Region.new(1, 1, 9, 1),
}

--- @type BufferMock
local without_gap = {
    content = {
        "const foo = () => {",
        "  console.log(\"foo \");",
        "};",
        "function bar() {",
        "  console.log(\"bar \");",
        "}",
    },
    region = Region.new(1, 1, 6, 1),
}

return {
    simplest = simplest,
    with_bigger_gap = with_bigger_gap,
    with_comment = with_comment,
    without_gap = without_gap,
}
