local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    if node_type == "rule_set" then
        return M._rule_set_query()
    elseif node_type == "declaration" then
        return M._declaration_query()
    end

    error("Unsupported node type: " .. node_type)
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

return M
