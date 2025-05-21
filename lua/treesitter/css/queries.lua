local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

M._declaration_query = function()
    return [[
        (declaration (property_name) @identifier) @block
    ]]
end

M._rule_set_query = function()
    return [[
        (rule_set (selectors) @identifier) @block
    ]]
end

M.query_by_node_as_table = {
    rule_set = M._rule_set_query(),
    declaration = M._declaration_query(),
}

return M
