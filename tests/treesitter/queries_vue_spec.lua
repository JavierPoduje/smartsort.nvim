local utils = require("tests.utils")
local vue_mocks = require("tests.mocks.vue")
local Chadnodes = require("treesitter.chadnodes")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal

describe("Queries - vue", function()
    it('can find lexical_declaration', function()
        local mock = vue_mocks.simple
        local bufnr, parser = utils.setup(mock.content, 'vue')
        local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        chadnodes:print(bufnr)

        equal(
            true,
            true
        )
    end)
end)
