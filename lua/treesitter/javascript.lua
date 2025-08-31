require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = {
        {
            char = ";",
            gap = {
                vertical_gap = 0,
                horizontal_gap = 0,
            },
            is_attached = true,
        },
        {
            char = ",",
            gap = {
                vertical_gap = 0,
                horizontal_gap = 0,
            },
            is_attached = true,
        }
    },
    handy_sortables = { "export_statement" },
    linkable = {
        "comment",
        "document",
    },
    query_by_node = {
        class_declaration = [[ [
          (export_statement (class_declaration (identifier) @identifier))
          (class_declaration (identifier) @identifier)
        ] @block ]],
        expression_statement = [[
            (expression_statement
              (call_expression function: (identifier) @identifier)
            ) @block
        ]],
        function_declaration = [[ [
            (export_statement (function_declaration (identifier) @identifier))
            (function_declaration (identifier) @identifier)
        ] @block ]],
        lexical_declaration = [[  [
           (export_statement (lexical_declaration (variable_declarator (identifier) @identifier)))
           (lexical_declaration (variable_declarator (identifier) @identifier))
        ] @block ]],
        method_definition = [[ (method_definition (property_identifier) @identifier) @block ]],
        pair = [[ (pair (property_identifier) @identifier) @block ]],
        public_field_definition = [[
            public_field_definition (property_identifier) @identifier) @block
        ]],
        switch_case = [[
            (switch_case
              value: ([ (binary_expression) (identifier) (number) (string) ] @identifier)
            ) @block
        ]],
    },
}
