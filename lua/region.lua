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

return Region
