--- @class Container
---
--- @field value any: the value of the container
---
--- @field map fun(self: Container, f: fun(a: any): any): Container
--- @field new fun(value: any): Container
--- @field of fun(value: any): Container


local Container = {}


--- Maps the value of the container using a function.
--- @param self Container the container to map
--- @param f fun(a: any): any the function to apply to the value
Container.map = function(self, f)
    assert(type(f) == "function", "Function expected for mapping")
    return Container:new(f(self.value))
end

function Container:new(value)
    assert(value ~= nil, "Value cannot be nil")

    Container.__index = Container
    local obj = {}
    setmetatable(obj, Container)

    obj.value = value
    return obj
end

Container.of = function(value)
    assert(value ~= nil, "Value cannot be nil")
    return Container:new(value)
end

return Container
