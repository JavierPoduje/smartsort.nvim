local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

M.query_by_node_as_table = {
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
}

return M
