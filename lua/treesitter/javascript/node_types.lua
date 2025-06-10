local M = {}

M.end_chars = {
    {
        char = ";",
        gap = {
            vertical_gap = 0,
            horizontal_gap = 0,
        },
        is_attached = true,
    },
    {
        char = ",",
        gap = {
            vertical_gap = 0,
            horizontal_gap = 0,
        },
        is_attached = true,
    }
}

M.linkable = {
    "comment",
    "document",
}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "lexical_declaration",
    "method_definition",
    "pair",
}

return M
