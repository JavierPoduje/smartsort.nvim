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
    -- "arrow_function",
}

return M
