local merge_tables = require("funcs").merge_tables
local javascript_definition = require('treesitter/javascript')

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

M.query_by_node_as_table = merge_tables(
    {
        interface_declaration = [[ [
           (interface_declaration (type_identifier) @identifier)
           (export_statement (interface_declaration (type_identifier) @identifier))
        ] @block ]],
        property_signature = [[ (property_signature (property_identifier) @identifier) @block ]],
    },
    javascript_definition.query_by_node
)

return M
