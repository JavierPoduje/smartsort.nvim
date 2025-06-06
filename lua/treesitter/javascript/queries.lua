local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    -- Check if the node is an export statement. If so, get the type of the first child.
    if node_type == "export_statement" then
        node_type = node:child(1):type()
    end

    local query = M.query_by_node_as_table[node_type]
    assert(query ~= nil, "Unsupported node type: " .. node_type)
    return query
end

M.query_by_node_as_table = {
    class_declaration = [[ [
        (export_statement (class_declaration (type_identifier) @identifier))
        (class_declaration (type_identifier) @identifier)
    ] @block ]],
    function_declaration = [[ [
        (export_statement (function_declaration (identifier) @identifier))
        (function_declaration (identifier) @identifier)
    ] @block ]],
    lexical_declaration = [[  [
       (export_statement (lexical_declaration (variable_declarator (identifier) @identifier)))
       (lexical_declaration (variable_declarator (identifier) @identifier))
    ] @block ]],
    method_definition = [[ (method_definition (property_identifier) @identifier) @block ]],
    pair = [[ (pair (property_identifier) @identifier) @block ]],
}

return M
