local Region = require("region")

local classes = {
    content = {
        '.c {',
        '  display: flex;',
        '}',
        '',
        '.b {',
        '  border-radius: 0.8rem;',
        '}',
        '',
        '.a {',
        '  display: flex;',
        '  background-color: red;',
        '',
        '  &:hover {',
        '    background-color: blue;',
        '  }',
        '}',
    },
    region = Region.new(1, 1, 16, 1),
}

local with_comments = {
    content = {
        '/**',
        ' * multiline comment',
        ' */',
        '.c {',
        '  display: flex;',
        '}',
        '',
        '// unnested comment',
        '',
        '',
        '// Nested comment',
        '.a {',
        '  display: flex;',
        '  background-color: red;',
        '}',
    },
    region = Region.new(1, 1, 15, 1),
}

return {
    classes = classes,
    with_comments = with_comments,
}
