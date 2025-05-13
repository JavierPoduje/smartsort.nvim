--- This module provides functions to build and manage queries for different node types in a tree-sitter parser.
--- All queries should have two matches:
--- * The first match is @block (the node itself), which is used to identify the node in the tree.
--- * The second match is the @identifier, which is later used to sort the block of code.

local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    if node_type == "script_element" then
        return M._script_element_query()
    end

    error("Unsupported node type: " .. node_type)
end

--- Return the query for a class_declaration
--- @return string
M._script_element_query = function()
    return [[
        (script_element) @injection
    ]]
end

return M
