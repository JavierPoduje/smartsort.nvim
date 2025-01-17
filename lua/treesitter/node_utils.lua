local M = {}

--- Calculate the "gap" between two nodes, where the gap is the number of rows between them.
---
--- @param n1 TSNode: the first node
--- @param n2 TSNode: the second node
--- @return number: the gap between the two nodes
M.gap = function(n1, n2)
    assert(n1 ~= nil, "Node 1 is nil")
    assert(n2 ~= nil, "Node 2 is nil")

    local _, _, n1_end_row, _ = n1:range()
    local n2_start_row, _, _, _ = n2:range()

    assert(n1_end_row < n2_start_row, "Node 1 is not before Node 2 or they're overlaping")

    return n2_start_row - n1_end_row - 1
end

return M
