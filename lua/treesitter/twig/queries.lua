local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

M.query_by_node_as_table = {
    statement_directive = [[
        (statement_directive
          (assignment_statement (variable) @identifier)
        ) @block
    ]],
}

return M
