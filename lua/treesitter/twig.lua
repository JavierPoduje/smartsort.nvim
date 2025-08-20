require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = {},
    handy_sortables = {},
    linkable = {
        "comment",
    },
    query_by_node = {
        statement_directive = [[
            (statement_directive
              (assignment_statement (variable) @identifier)
            ) @block
        ]],
    },
}
