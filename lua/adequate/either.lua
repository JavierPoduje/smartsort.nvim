--- @class Either
--- @field value any: the value contained in the Either
---
--- @field new fun(value: any): self
--- @field of fun(value: any): self

local Either = {}
Either.__index = Either

--- @class Right: Either
---
--- @field inspect fun(self: Right): string
--- @field map fun(self: Right, f: fun(any): Either): self

--- Creates a new Either instance with the given value
--- @param value any: the value to wrap in a Either
--- @return Either
function Either:new(value)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.value = value
    return obj
end

local Right = {}
Right.__index = Right
setmetatable(Right, Either)

--- Returns a string representation of the Right instance for inspection.
--- @return string
Right.inspect = function(self)
    local val_str
    if type(self.value) == "string" then
        val_str = string.format("'%s'", self.value)
    else
        val_str = tostring(self.value)
    end
    return string.format("Right(%s)", val_str)
end

Right.__tostring = Right.inspect

--- Applies a function to the value of a Right instance and returns a new Right instance with the result.
--- @param self Right
--- @param f function
--- @return Either
Right.map = function(self, f)
    return Either.of(f(self.value))
end

--- @class Left: Either
---
--- @field new fun(value: any): Left
--- @field inspect fun(self: Left): string
--- @field left fun(value: any): self
--- @field map fun(self: Left, f: fun(any): Left): self

local Left = {}
Left.__index = Left
setmetatable(Left, Either)

--- Static method to create a Either instance from a value
--- @param value any: the value to wrap in a Either
--- @return Right
Either.of = function(value)
    return Right:new(value)
end

--- Creates a new Left instance with the given value
--- @param value any: the value to wrap in a Either
--- @return Left
function Left:new(value)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.value = value
    return obj
end

--- Returns a string representation of the Left instance for inspection.
--- @return string
Left.inspect = function(self)
    local val_str
    if type(self.value) == "string" then
        val_str = string.format("'%s'", self.value)
    else
        val_str = tostring(self.value)
    end
    return string.format("Left(%s)", val_str)
end

--- Creates a new Left instance with the given value
--- @param value any: the value to wrap in a Left
--- @return Left
Left.left = function(value)
    return Left:new(value)
end

--- Applies a function to the value of a Left instance and returns a new Left instance with the result.
--- @param f function
--- @return Left
Left.map = function(self, f)
    return self
end

return {
    Either = Either,
    Right = Right,
    Left = Left,
}
