local Chadnodes = require("chadnodes")
local f = require("funcs")
local scss_mocks = require("tests.mocks.scss")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

local default_setup = utils.default_setup

describe("chadnodes: sort - scss", function()
    it("should sort classes alphabetically", function()
        local mock = scss_mocks.classes
        local bufnr, parser = utils.setup(mock.content, "scss")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser)
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            ".a {\n  display: flex;\n  background-color: red;\n\n  &:hover {\n    background-color: blue;\n  }\n}",
            ".b {\n  border-radius: 0.8rem;\n}",
            ".c {\n  display: flex;\n}",
        }))
    end)

    it("should consider single and multiple line coments", function()
        local mock = scss_mocks.with_comments
        local bufnr, parser = utils.setup(mock.content, "scss")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser)
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            "/**\n * multiline comment\n */",
            ".a {\n  display: flex;\n  background-color: red;\n}",
            "// unnested comment",
            "// Nested comment",
            ".c {\n  display: flex;\n}",
        }))
    end)
end)
