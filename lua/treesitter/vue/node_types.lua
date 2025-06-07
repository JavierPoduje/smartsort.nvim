local M = {}

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

M.linkable = {}

M.sortable = {
    "directive_attribute",
}

return M
