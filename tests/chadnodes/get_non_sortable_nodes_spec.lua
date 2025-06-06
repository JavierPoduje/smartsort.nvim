local Chadnodes = require("chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: get_linkable_nodes", function()
    it("get_linkable_nodes shouldn't consider sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local linkables = cnodes:get_linkable_nodes()

        truthy(vim.deep_equal(Chadnodes.from_chadnodes(parser, linkables):debug(bufnr), {
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
        }))
    end)
end)
