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

local interface_properties = {
    content = {
        'export interface SomeInterface {',
        '  c: {',
        '    baz: string;',
        '    qux: number;',
        '    extra: {',
        '      zig: string;',
        '    };',
        '  };',
        '  b: {',
        '    foo: string;',
        '    bar: boolean;',
        '  }',
        '  a: number;',
        '}',
    },
    region = Region.new(2, 1, 13, 12),
}

local three_interfaces = {
    content = {
        'export interface B {',
        '  b: number;',
        '}',
        '',
        'export interface C {',
        '  c: boolean;',
        '}',
        '',
        'interface A {',
        '  a: string;',
        '}',
    },
    region = Region.new(1, 1, 11, 1),
}

local two_classes = {
    content = {
        'class BClass {',
        '  b: number;',
        '  constructor(b: number) {',
        '    this.b = b;',
        '  }',
        '}',
        '',
        'class AClass {',
        '  a: number;',
        '  constructor(x: number, y: number) {',
        '    this.a = x;',
        '  }',
        '}',
    },
    region = Region.new(1, 1, 13, 1),
}

local point_class = {
    content = {
        'class Point {',
        '  x: number;',
        '  y: number;',
        '',
        '  constructor(x: number, y: number) {',
        '    this.x = x;',
        '    this.y = y;',
        '  }',
        '',
        '  scale(n: number): void {',
        '    this.x *= n;',
        '    this.y *= n;',
        '  }',
        '',
        '  asString(): string {',
        '    return `(${this.x}, ${this.y})`;',
        '  }',
        '}',
    },
    region = Region.new(10, 1, 18, 1),
}

local middle_size = {
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
        '// comment attached to the function zit',
        'const zit = () => {',
        '  console.log("zit");',
        '};',
        '',
        '// nested comment',
        '/**',
        ' * This is a comment',
        ' */',
        'function bar() {',
        '  console.log("bar");',
        '}',
    },
    region = Region.new(8, 1, 21, 1),
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

--- @type BufferMock
local with_nested_comments = {
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
        '// this is a nested comment',
        '/**',
        ' * This is a comment',
        ' */',
        'function bar() {',
        '  console.log("bar");',
        '}',
    },
    region = Region.new(1, 1, 16, 1),
}

return {
    commented_functions = commented_functions,
    interface_properties = interface_properties,
    middle_size = middle_size,
    node_with_comment = node_with_comment,
    point_class = point_class,
    simplest = simplest,
    three_interfaces = three_interfaces,
    two_classes = two_classes,
    with_bigger_gap = with_bigger_gap,
    with_comment = with_comment,
    with_nested_comments = with_nested_comments,
    without_gap = without_gap,
}
