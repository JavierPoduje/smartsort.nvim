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
        function_declaration = [[
            (function_declaration (identifier) @identifier) @block
        ]],
        keyed_element = [[
            (keyed_element (literal_element) @identifier) @block
        ]],
        method_declaration = [[
            (method_declaration (field_identifier) @identifier) @block
        ]],
        short_var_declaration = [[
            (short_var_declaration (expression_list) @identifier) @block
        ]],
        type_case = [[
            (type_switch_statement
                (type_case
                    [
                        (qualified_type) @identifier
                        (type_identifier) @identifier
                    ]
                ) @block
            )
        ]],
    },
}
