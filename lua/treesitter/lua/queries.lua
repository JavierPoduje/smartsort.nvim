local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end


M._function_declaration_query = function()
    return [[
        (function_declaration (identifier) @identifier) @block
    ]]
end

M._assignment_statement_query = function()
    return [[
        (assignment_statement
          (variable_list
            (dot_index_expression
              field: (identifier) @identifier))
          ) @block
    ]]
end

M._variable_declaration_query = function()
    return [[
        (variable_declaration
            (assignment_statement
                (variable_list (identifier) @identifier)
            )
        ) @block
    ]]
end

M.query_by_node_as_table = {
    assignment_statement = M._assignment_statement_query(),
    function_declaration = M._function_declaration_query(),
    variable_declaration = M._variable_declaration_query(),
}

return M
