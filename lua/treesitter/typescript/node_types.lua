local Behavior = require("treesitter/behavior")

local M = {}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "interface_declaration",
    "lexical_declaration",
    "method_definition",
    "property_signature",
}

M.non_sortable = {
    "comment",
}

M.end_chars = {
    {
        char = ";",
        behavior = Behavior.Attached,
        gap = 0,
    }
}

return M
