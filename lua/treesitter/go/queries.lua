local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    local query = M.query_by_node_as_table[node_type]
    assert(query ~= nil, "Unsupported node type: " .. node_type)
    return query
end

M.query_by_node_as_table = {
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
}

return M
