local M = {}

M.sortable = {
    "class_declaration",
    "export_statement",
    "function_declaration",
    "lexical_declaration",
    "method_definition",
    "pair",
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

return M

