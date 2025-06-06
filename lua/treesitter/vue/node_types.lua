local M = {}

M.sortable = {
    "directive_attribute",
}

M.linkable = {}

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
