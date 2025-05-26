local M = {}

M.sortable = {
    "directive_attribute",
}

M.non_sortable = {}

M.end_chars = {
    {
        char = "/>",
        gap = {
            vertical_gap = 0,
            horizontal_gap = 0,
        },
        is_attached = false,
    }
}

return M
