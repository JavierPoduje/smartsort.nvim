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

return {
    class_declaration = class_declaration,
}
