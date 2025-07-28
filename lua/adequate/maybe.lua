local Maybe = {}

--- @class Maybe
---
--- @field value any: the value contained in the Maybe
---
--- @field inspect fun(self: Maybe): string
--- @field isNothing fun(self: Maybe): boolean
--- @field map fun(self: Maybe, fn: function): self
--- @field new fun(value: any): self
--- @field of fun(value: any): self

--- returns a string representation of the Maybe
--- @param self Maybe: the Maybe instance
--- @return string
Maybe.inspect = function(self)
    return self:isNothing() and 'Nothing' or ('Just(' .. tostring(self.value) .. ')')
end

--- Returns true if the Maybe is Nothing, false otherwise
--- @param self Maybe
--- @return boolean
Maybe.isNothing = function(self)
    print("self.value", self.value)
    return self.value == nil
end

--- Creates a new Maybe passing the value to the given function. If it's nothing, returns itself.
--- @param self Maybe
--- @param fn function: the function to apply to the value
--- @return Maybe
Maybe.map = function(self, fn)
    if self:isNothing() then
        return self
    end
    return Maybe.of(fn(self.value))
end

--- Creates a new Maybe instance with the given value
--- @param value any: the value to wrap in a Maybe
--- @return Maybe
function Maybe:new(value)
    local obj = {}
    setmetatable(obj, self)
    Maybe.__index = Maybe
    obj.value = value
    return obj
end

--- Static method to create a Maybe instance from a value
--- @param value any: the value to wrap in a Maybe
--- @return Maybe
Maybe.of = function(value)
    return Maybe:new(value)
end

return Maybe
