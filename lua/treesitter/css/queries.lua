local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    if node_type == "rule_set" then
        return M._rule_set_query()
    end

    error("Unsupported node type: " .. node_type)
end

M._rule_set_query = function()
    return [[
        (rule_set (selectors) @identifier) @block
    ]]
end

return M
