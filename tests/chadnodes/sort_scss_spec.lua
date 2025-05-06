local Chadnodes = require("treesitter.chadnodes")
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

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node =
                ".a {\n  display: flex;\n  background-color: red;\n\n  &:hover {\n    background-color: blue;\n  }\n}",
                sortable_idx = ".a"
            },
            {
                node = ".b {\n  border-radius: 0.8rem;\n}",
                sortable_idx = ".b"
            },
            {
                node = ".c {\n  display: flex;\n}",
                sortable_idx = ".c"
            }
        }))
    end)

    it("should consider single and multiple line coments", function()
        local mock = scss_mocks.with_comments
        local bufnr, parser = utils.setup(mock.content, "scss")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
            {
                node = "/**\n * multiline comment\n */",
                sortable_idx = ""
            },
            {
                node = ".a {\n  display: flex;\n  background-color: red;\n}",
                sortable_idx = ".a"
            },
            {
                node = "// unnested comment",
                sortable_idx = ""
            },
            {
                node = "// Nested comment",
                sortable_idx = ""
            },
            {
                node = ".c {\n  display: flex;\n}",
                sortable_idx = ".c"
            }
        }))
    end)
end)
