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
--- @field public set_gaps fun(self: EndChar, endchar_cnode: Chadnode, other: Chadnode)

local EndChar = {}

--- @param char string: the character to create the EndChar from
--- @param gap Gap: the gap between the character and the next node
--- @param is_attached boolean: true if the character is attached to the previous node
function EndChar:new(char, gap, is_attached)
    EndChar.__index = EndChar
    local obj = {}
    setmetatable(obj, EndChar)

    obj.char = char
    obj.gap = gap
    obj.is_attached = is_attached

    return obj
end

--- @param self EndChar
--- @return number: the horizontal gap
EndChar.get_horizontal_gap = function(self)
    return self.gap.horizontal_gap or 0
end

--- @param self EndChar
--- @return number: the vertical gap
EndChar.get_vertical_gap = function(self)
    return self.gap.vertical_gap or 0
end

--- @param self EndChar
--- @param endchar_cnode Chadnode: the cnode to which end_char belongs
--- @param other Chadnode: the node right before the end_char cnode
EndChar.set_gaps = function(self, endchar_cnode, other)
    self.gap.vertical_gap = other:gap(endchar_cnode)
    if self.gap.vertical_gap == -1 then
        self.gap.horizontal_gap = other:horizontal_gap(endchar_cnode)
    end
end

return EndChar
