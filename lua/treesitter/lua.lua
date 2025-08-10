require('treesitter/types')

--- @type ChadLanguageConfig
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
    sortable = {
        "assignment_statement",
        "function_declaration",
        "field",
        "variable_declaration",
    }
}
