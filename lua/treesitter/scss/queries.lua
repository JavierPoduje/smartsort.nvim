local merge_tables = require("funcs").merge_tables

local css_queries = require("treesitter.css.queries")

local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

M.query_by_node_as_table = merge_tables(
    {},
    css_queries.query_by_node_as_table
)

return M
