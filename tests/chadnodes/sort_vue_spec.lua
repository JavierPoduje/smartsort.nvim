local Chadnodes = require("chadnodes")
local utils = require("tests.utils")
local vue_mocks = require("tests.mocks.vue")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort - vue", function()
    it("should sort alphabetically", function()
        local mock = vue_mocks.simple
        local bufnr, parser = utils.setup(mock.content, "vue")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "const aaa =\n  ref('Hello World');",
                sortable_idx = "aaa"
            },
            {
                node = "const bbb = ref('another');",
                sortable_idx = "bbb"
            }
        }))
    end)
end)
