local merge_tables = require("funcs").merge_tables
local javascript_queries = require("treesitter.javascript.queries")

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

M._property_signature_query = function()
    return [[
        (property_signature (property_identifier) @identifier) @block
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

M.query_by_node_as_table = merge_tables(
    {
        interface_declaration = M._interface_declaration_query(),
        property_signature = M._property_signature_query(),
    },
    javascript_queries.query_by_node_as_table
)

return M
