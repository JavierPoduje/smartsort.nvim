local f = require("funcs")
local merge_arrays = f.merge_arrays
local merge_tables = f.merge_tables
local javascript_node_types = require("treesitter.javascript.node_types")

local M = {}

M.end_chars = merge_tables({}, javascript_node_types.end_chars)
M.linkable = merge_arrays({}, javascript_node_types.linkable)
M.sortable = merge_arrays({
    "interface_declaration",
    "pair",
    "property_signature",
}, javascript_node_types.sortable)

return M
