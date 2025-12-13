require('treesitter/types')

--- @type LanguageConfig

return {
    end_chars = {},
    handy_sortables = {},
    linkable = {
        "comment",
    },
    query_by_node = {
        expression_statement = [[
            (expression_statement
                (assignment
                    left: (identifier) @identifier
                )
            ) @block
        ]],
        class_definition = [[
            (class_definition
                name: (identifier) @identifier
            ) @block
        ]],
        function_definition = [[
            (function_definition
                name: (identifier) @identifier
            ) @block
        ]],
    },
}
