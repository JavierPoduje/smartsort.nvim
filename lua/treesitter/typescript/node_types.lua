local javascript_node_types = require("treesitter.javascript.node_types")

local M = {}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "interface_declaration",
    "lexical_declaration",
    "method_definition",
    "pair",
    "property_signature",
}

M.linkable = {
    "comment",
}

M.end_chars = {
    {
        char = ";",
        gap = {
            vertical_gap = 0,
            horizontal_gap = 0,
        },
        is_attached = true,
    }
}

return M
