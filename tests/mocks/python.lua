local Region = require("region")

local two_assignments = {
    content = [[
foo = "foo"
bar = "bar"]],
    region = Region.new(1, 1, 2, 11),
}

local two_functions = {
    content = [[
def foo():
    print("foo")

def bar():
    print("bar")]],
    region = Region.new(1, 1, 5, 16),
}

local two_classes = {
    content = [[
class BClass:
    def __init__(self, b):
        self.b = b

class AClass:
    def __init__(self, a):
        self.a = a]],
    region = Region.new(1, 1, 11, 18),
}

return {
    two_assignments = two_assignments,
    two_classes = two_classes,
    two_functions = two_functions,
}
