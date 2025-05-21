local M = {}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "lexical_declaration",
    "method_definition",
}

M.non_sortable = {
    "comment",
}

M.end_chars = {
    {
        char = ";",
        gap = 0,
        is_attached = true,
    }
}

return M

