local M = {}

M.sortable = {
    "rule_set",
}

M.non_sortable = {
    "comment",
}

--- @param node_type string: the node type
--- @return boolean: true if the node type can be linked to another sortable node, false otherwise.
M.is_linkable = function(node_type)
    for _, node in ipairs(M.non_sortable) do
        if node == node_type then
            return true
        end
    end
    return false
end

M.sortable_and_non_sortable = function()
    local nodes = {}
    for _, node in ipairs(M.sortable) do
        table.insert(nodes, node)
    end
    for _, node in ipairs(M.non_sortable) do
        table.insert(nodes, node)
    end
    return nodes
end

return M
