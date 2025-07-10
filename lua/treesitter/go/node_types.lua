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
    "function_declaration",
    "keyed_element",
    "method_declaration",
    "short_var_declaration",
    "type_case",
}

return M
