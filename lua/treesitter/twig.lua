require('treesitter/types')

--- @type ChadLanguageConfig
return {
    end_chars = {},
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
    sortable = {
        "statement_directive",
    }
}
