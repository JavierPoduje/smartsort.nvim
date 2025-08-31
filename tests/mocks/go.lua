local Region = require("region")

local switch_statement = {
    content = [[
package main

func main() {
	switch v := value.(type) {
	case string:
		fmt.Println("string")
	case int:
		fmt.Println("int")
	case bool:
		fmt.Println("bool")
	}
}
]],
    region = Region.new(5, 1, 10, 21),
}

return {
    switch_statement = switch_statement,
}
