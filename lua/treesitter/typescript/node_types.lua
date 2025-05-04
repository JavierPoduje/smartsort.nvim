local M = {}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "interface_declaration",
    "lexical_declaration",
    "method_definition",
    -- "arrow_function"
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
