local Behavior = require("treesitter/behavior")

local M = {}

M.sortable = {
    "directive_attribute",
}

M.non_sortable = {}

M.end_chars = {
    {
        char = "/>",
        behavior = Behavior.Deattached,
        gap = 0,
    }
}

return M
