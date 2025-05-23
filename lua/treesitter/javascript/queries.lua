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

--- Return the query for a class_declaration
--- @return string
M._class_declaration_query = function()
    return [[
        [
            (export_statement (class_declaration (type_identifier) @identifier))
            (class_declaration (type_identifier) @identifier)
        ] @block
    ]]
end

--- Return the query for a function declaration
--- @return string
M._function_declaration_query = function()
    return [[
        [
            (export_statement (function_declaration (identifier) @identifier))
            (function_declaration (identifier) @identifier)
        ] @block
    ]]
end

--- Return the query for a lexical declaration
--- @return string
M._lexical_declaration_query = function()
    return [[
        [
           (export_statement (lexical_declaration (variable_declarator (identifier) @identifier)))
           (lexical_declaration (variable_declarator (identifier) @identifier))
        ] @block
    ]]
end

M._method_definition_query = function()
    return [[
        [
            (export_statement (method_definition (property_identifier) @identifier))
            (method_definition (property_identifier) @identifier)
        ] @block
    ]]
end

M.query_by_node_as_table = {
    class_declaration = M._class_declaration_query(),
    function_declaration = M._function_declaration_query(),
    lexical_declaration = M._lexical_declaration_query(),
    method_definition = M._method_definition_query(),
}

return M
