local M = {}

M.end_chars = {
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
}

M.sortable = {
    "assignment_statement",
    "function_declaration",
    "field",
    "variable_declaration",
}

return M
