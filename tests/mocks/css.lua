local Region = require("region")

local classes = {
    content = {
        '/*',
        ' * This is',
        ' * a multi-line',
        ' * comment',
        ' */',
        '.cclass .dclass {',
        '  color: green;',
        '}',
        '.bclass {',
        '  color: blue;',
        '}',
        '',
        '/* This is a comment */',
        '.aclass {',
        '  color: red;',
        '}',
    },
    region = Region.new(1, 1, 16, 1),
}

return {
    classes = classes,
}
