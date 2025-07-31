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
        local bufnr, parser = utils.setup(vim.fn.split(mock.content, "\n"), "css")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort({ non_sortable_behavior = "preserve" }):stringified_cnodes(), {
            "/*\n * This is\n * a multi-line\n * comment\n */",
            ".aclass {\n  color: red;\n}",
            ".bclass {\n  color: blue;\n}",
            "/* This is a comment */",
            ".cclass .dclass {\n  color: green;\n}",
        }))
    end)
end)
