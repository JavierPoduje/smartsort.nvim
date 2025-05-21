--- This module provides functions to build and manage queries for different node types in a tree-sitter parser.
--- All queries should have two matches:
--- * The first match is @block (the node itself), which is used to identify the node in the tree.
--- * The second match is the @identifier, which is later used to sort the block of code.

local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    -- Check if the node is an export statement. If so, get the type of the first child.
    if node_type == "export_statement" then
        node_type = node:child(1):type()
    end

    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

M._property_signature_query = function()
    return [[
        (property_signature (property_identifier) @identifier) @block
    ]]
end

--- Return the query for a lexical declaration
--- @return string
M._lexical_declaration_query = function()
    return [[
        (lexical_declaration (variable_declarator (identifier) @identifier)) @block
    ]]
end

--- Return the query for a function declaration
--- @return string
M._function_declaration_query = function()
    return [[
        [
          (export_statement (function_declaration (identifier) @identifier)) @block
          (function_declaration (identifier) @identifier) @block
        ]
    ]]
end

--- Return the query for a function declaration
--- @return string
M._interface_declaration_query = function()
    return [[
        [
           (interface_declaration (type_identifier) @identifier)
           (export_statement (interface_declaration (type_identifier) @identifier))
         ] @block
    ]]
end

M._method_definition_query = function()
    return [[
        (method_definition (property_identifier) @identifier) @block
    ]]
end

--- Return the query for a class_declaration
--- @return string
M._class_declaration_query = function()
    return [[
        (class_declaration (type_identifier) @identifier) @block
    ]]
end

M.query_by_node_as_table = {
    function_declaration = M._function_declaration_query(),
    lexical_declaration = M._lexical_declaration_query(),
    method_definition = M._method_definition_query(),
    class_declaration = M._class_declaration_query(),
    interface_declaration = M._interface_declaration_query(),
    property_signature = M._property_signature_query(),
}

return M
