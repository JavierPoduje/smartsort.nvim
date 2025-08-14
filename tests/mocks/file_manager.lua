local Region = require("region")

local no_indentation = {
    content = [[
cosnt hola = 'hola';
    ]],
    language = "javascript",
    region = Region.new(1, 1, 1, 20),
}

local one_tab = {
    content = [[
	const foo = () => {
		console.log("foo");
	};
    ]],
    language = "javascript",
    region = Region.new(1, 1, 3, 3),
}

local two_spaces = {
    content = [[
  const foo = () => {
    console.log("foo");
  };
    ]],
    language = "javascript",
    region = Region.new(1, 1, 3, 6),
}

local four_spaces = {
    content = [[
            const bar = () => {
        console.log("bar");
    };
    ]],
    language = "javascript",
    region = Region.new(1, 1, 3, 6),
}


return {
    four_spaces = four_spaces,
    no_indentation = no_indentation,
    one_tab = one_tab,
    two_spaces = two_spaces,
}
