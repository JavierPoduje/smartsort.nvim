--- @class Region
--- @field srow number: the start row
--- @field scol number: the start column
--- @field erow number: the end row
--- @field ecol number: the end column

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

return Region
