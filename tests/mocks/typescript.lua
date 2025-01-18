local simplest = {
    "const foo = () => {",
    "  console.log(\"foo \");",
    "};",
    "",
    "function bar() {",
    "  console.log(\"bar \");",
    "}",
}

local with_bigger_gap = {
    "const foo = () => {",
    "  console.log(\"foo \");",
    "};",
    "",
    "",
    "",
    "function bar() {",
    "  console.log(\"bar \");",
    "}",
}

local without_bigger_gap = {
    "const foo = () => {",
    "  console.log(\"foo \");",
    "};",
    "function bar() {",
    "  console.log(\"bar \");",
    "}",
}

return {
    simplest = simplest,
    with_bigger_gap = with_bigger_gap,
    without_bigger_gap = without_bigger_gap,
}
