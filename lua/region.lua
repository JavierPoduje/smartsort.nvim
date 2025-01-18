--- @class Region
--- @field srow number: the start row
--- @field scol number: the start column
--- @field erow number: the end row
--- @field ecol number: the end column
--- @field new fun(srow: number, scol: number, erow: number, ecol: number): Region
--- @field from_selection fun(): Region
--- @field from_node fun(node: TSNode): Region

local Region = {}
Region.__index = Region

--- Create a new Region
--- @param srow number: the start row
--- @param scol number: the start column
--- @param erow number: the end row
--- @param ecol number: the end column
--- @return Region
Region.new = function(srow, scol, erow, ecol)
    local self = setmetatable({}, Region)
    assert(srow ~= nil, "Can't create a Region from this nil start row")
    assert(scol ~= nil, "Can't create a Region from this nil start row")
    assert(erow ~= nil, "Can't create a Region from this nil end row")
    assert(ecol ~= nil, "Can't create a Region from this nil end row")

    self.srow = srow
    self.scol = scol
    self.erow = erow
    self.ecol = ecol

    return self
end

--- Returns a `Region` from the current visual selection
--- @return Region
Region.from_selection = function()
    local srow = vim.fn.line("'<")
    local scol = vim.fn.col("'<")
    local erow = vim.fn.line("'>")
    local ecol = vim.fn.col("'>")

    local last_line = vim.api.nvim_buf_get_lines(0, erow - 1, erow, true)[1]
    local line_length = vim.str_utfindex(last_line, #last_line)
    ecol = math.min(ecol, line_length)

    return Region.new(srow, scol, erow, ecol)
end

--- Returns a `Region` from a `TSNode`
--- @param node TSNode: the node
--- @return Region
Region.from_node = function(node)
    assert(node ~= nil, "Can't create a Region from this `nil` piece of shit node")
    local srow, scol, erow, ecol = node:range()
    return Region.new(srow, scol, erow, ecol)
end

return Region
