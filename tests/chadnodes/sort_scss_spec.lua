local Chadnodes = require("chadnodes")
local scss_mocks = require("tests.mocks.scss")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: sort - scss", function()
    it("should sort classes alphabetically", function()
        local mock = scss_mocks.classes
        local bufnr, parser = utils.setup(mock.content, "scss")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():stringified_cnodes(), {
            ".a {\n  display: flex;\n  background-color: red;\n\n  &:hover {\n    background-color: blue;\n  }\n}",
            ".b {\n  border-radius: 0.8rem;\n}",
            ".c {\n  display: flex;\n}",
        }))
    end)

    it("should consider single and multiple line coments", function()
        local mock = scss_mocks.with_comments
        local bufnr, parser = utils.setup(mock.content, "scss")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():stringified_cnodes(), {
            "/**\n * multiline comment\n */",
            ".a {\n  display: flex;\n  background-color: red;\n}",
            "// unnested comment",
            "// Nested comment",
            ".c {\n  display: flex;\n}",
        }))
    end)
end)
