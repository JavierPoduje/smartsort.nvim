local merge_tables = require("funcs").merge_tables
local javascript_node_types = require("treesitter.javascript.node_types")

local M = {}

M.end_chars = merge_tables({}, javascript_node_types.end_chars)

M.linkable = merge_tables({}, javascript_node_types.linkable)

M.sortable = merge_tables({
    "interface_declaration",
    "pair",
    "property_signature",
}, javascript_node_types.sortable)

return M
