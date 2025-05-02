local M = {}

--- @param node_type string: the type of the node
--- @return boolean
M.is_supported_node_type = function(node_type)
    local supported_node_types = {
        "lexical_declaration",
    }

    for _, supported_node_type in ipairs(supported_node_types) do
        if node_type == supported_node_type then
            return true
        end
    end

    return false
end

--- @param node_type string: the type of the node
--- @return string
M.query_by_node_type = function(node_type)
    assert(M.is_supported_node_type(node_type), "Unsupported node type: " .. node_type)

    if node_type == "lexical_declaration" then
        return M._lexical_declaration_query()
    end

    error("Unsupported node type: " .. node_type)
end

--- Return the query for a lexical declaration
--- @return string
M._lexical_declaration_query = function()
    return [[
        (lexical_declaration (variable_declarator (identifier) @identifier)) @node
    ]]
end

return M
