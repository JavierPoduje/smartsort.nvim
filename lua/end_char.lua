--- @class EndChar
---
--- @field public char string: the character
--- @field public gap Gap: the Gap between the character and the next node
--- @field public is_attached boolean: true if the character is attached to the node
--- @field public new fun(): EndChar
---
--- @field public get_horizontal_gap fun(self: EndChar): number
--- @field public get_vertical_gap fun(self: EndChar): number
--- @field public new fun(char: string, gap: Gap, is_attached: boolean): EndChar

local EndChar = {}

--- @param char string: the character to create the EndChar from
--- @param gap Gap: the gap between the character and the next node
--- @param is_attached boolean: true if the character is attached to the previous node
function EndChar:new(char, gap, is_attached)
    EndChar.__index = EndChar
    local obj = {}
    setmetatable(obj, EndChar)

    obj.char = char
    obj.gap = gap or { vertical_gap = 0, horizontal_gap = 0 }
    obj.is_attached = is_attached

    return obj
end

--- @param self EndChar
--- @return number: the vertical gap
EndChar.get_vertical_gap = function(self)
    return self.gap.vertical_gap or 0
end

--- @param self EndChar
--- @return number: the horizontal gap
EndChar.get_horizontal_gap = function(self)
    return self.gap.horizontal_gap or 0
end

return EndChar
