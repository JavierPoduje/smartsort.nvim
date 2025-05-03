local typescript_node_types = require("treesitter.typescript.node_types")

--- This module provides functions to build and manage queries for different node types in a tree-sitter parser.
--- All queries should have two matches:
--- * The first match is @block (the node itself), which is used to identify the node in the tree.
--- * The second match is the @identifier, which is later used to sort the block of code.

local M = {}

--- @param node_type string: the type of the node
--- @return boolean
M.is_supported_node_type = function(node_type)
    for _, supported_node_type in ipairs(typescript_node_types.sortable) do
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

    if node_type == "function_declaration" then
        return M._function_declaration_query()
    elseif node_type == "lexical_declaration" then
        return M._lexical_declaration_query()
    elseif node_type == "method_definition" then
        return M._method_definition_query()
    end

    error("Unsupported node type: " .. node_type)
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
        (function_declaration (identifier) @identifier) @block
    ]]
end

M._method_definition_query = function()
    return [[
        (method_definition (property_identifier) @identifier) @block
    ]]
end

--- @param lang string: the language to query
--- @param query_str string: the query string
--- @return vim.treesitter.Query
M.build = function(lang, query_str)
    local query = vim.treesitter.query.parse(lang, query_str)
    return query
end

return M
