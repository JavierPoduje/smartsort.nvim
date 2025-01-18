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
    region = Region.new(1, 1, 9, 2147483647),
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
    region = Region.new(1, 1, 9, 2147483647),
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
    region = Region.new(1, 1, 9, 2147483647),
}

return {
    simplest = simplest,
    with_bigger_gap = with_bigger_gap,
    without_gap = without_gap,
}
