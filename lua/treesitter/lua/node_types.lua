local M = {}

M.sortable = {
    "assignment_statement",
    "function_declaration",
}

M.non_sortable = {
    "comment",
}

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
