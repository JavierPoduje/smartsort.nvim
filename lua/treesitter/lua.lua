require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = {
        {
            char = ",",
            gap = {
                vertical_gap = 0,
                horizontal_gap = 0,
            },
            is_attached = true,
        }
    },
    handy_sortables = {},
    linkable = {
        "comment",
    },
    query_by_node = {
        assignment_statement = [[
            (assignment_statement
              (variable_list
                (dot_index_expression
                  field: (identifier) @identifier))
            ) @block
        ]],
        field = [[ (field (identifier) @identifier) @block ]],
        function_call = [[ (function_call name: (identifier) @identifier) @block ]],
        function_declaration = [[
            ([
                (function_declaration (identifier) @identifier)
                (function_declaration
                    (method_index_expression
                        method: (identifier) @identifier))
            ]) @block
        ]],
        variable_declaration = [[
            (variable_declaration
                (assignment_statement
                    (variable_list (identifier) @identifier)
                )
            ) @block
        ]],
    },
}
