local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    if node_type == "assignment_statement" then
        return M._assignment_statement_query()
    elseif node_type == "function_declaration" then
        return M._function_declaration_query()
    elseif node_type == "variable_declaration" then
        return M._variable_declaration_query()
    end

    error("Unsupported node type: " .. node_type)
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

return M
