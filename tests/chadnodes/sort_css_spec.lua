local Chadnodes = require("treesitter.chadnodes")
local css_mocks = require("tests.mocks.css")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort - css", function()
    it("should sort alphabetically", function()
        local mock = css_mocks.classes
        local bufnr, parser = utils.setup(mock.content, "css")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "/*\n * This is\n * a multi-line\n * comment\n */",
                sortable_idx = ""
            },
            {
                node = ".aclass {\n  color: red;\n}",
                sortable_idx = ".aclass"
            },
            {
                node = ".bclass {\n  color: blue;\n}",
                sortable_idx = ".bclass"
            },
            {
                node = "/* This is a comment */",
                sortable_idx = ""
            },
            {
                node = ".cclass .dclass {\n  color: green;\n}",
                sortable_idx = ".cclass .dclass"
            }
        }))
    end)
end)
