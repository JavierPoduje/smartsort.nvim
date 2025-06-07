local Chadnodes = require("chadnodes")
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
                sort_key = ""
            },
            {
                node = ".aclass {\n  color: red;\n}",
                sort_key = ".aclass"
            },
            {
                node = ".bclass {\n  color: blue;\n}",
                sort_key = ".bclass"
            },
            {
                node = "/* This is a comment */",
                sort_key = ""
            },
            {
                node = ".cclass .dclass {\n  color: green;\n}",
                sort_key = ".cclass .dclass"
            }
        }))
    end)
end)
