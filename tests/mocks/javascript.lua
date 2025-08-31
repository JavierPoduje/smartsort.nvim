local Region = require("region")

local class_declaration = {
    content = [[
class Zebra {
  // implementation
}

class Apple {
  // implementation
}

export class Banana {
  // implementation
}
]],
    region = Region.new(1, 1, 11, 1),
}

local field_definition = {
    content = [[
class MyClass {
    zebra = "zebra";
    apple = "apple";
    banana = "banana";
}
]],
    region = Region.new(2, 1, 4, 22),

}

return {
    class_declaration = class_declaration,
    field_definition = field_definition,
}
