local Chadnodes = require("chadnodes")
local LanguageQuery = require("treesitter.language_query")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local same = assert.are.same

describe("language-query", function()
    it("queries by node", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local fst_cnode = cnodes:node_by_idx(2)
        local language_query = LanguageQuery:new("typescript")

        if fst_cnode == nil then
            error("No nodes found in the mock region")
        end

        local sortable_group = language_query:sortable_group_by_node(fst_cnode.ts_node)

        same(sortable_group, {
            "function_declaration",
            "lexical_declaration_function",
            "method_definition",
        })
    end)
end)
