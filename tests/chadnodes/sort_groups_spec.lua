local Chadnodes = require("chadnodes")
local f = require("funcs")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

local default_setup = utils.default_setup

describe("chadnodes: sort groups", function()
    it("non_sortable_behavior `preserve`; non_target_sortable_behavior `preserve`", function()
        local mock = typescript_mocks.funcs_and_vars
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes, _, first_sortable_node_idx = Chadnodes.from_region(bufnr, mock.region, parser, { use_sort_groups = true })
        local opts = f.merge_tables(default_setup, {
            first_sortable_node_idx = first_sortable_node_idx,
            use_sort_groups = true,
        })

        truthy(vim.deep_equal(cnodes:sort(opts):stringified_cnodes(), {
            'const aaa = (something: string): string => something + " concat";',
            'const ddd = (something: string): string => something + " concat";',
            'const ccc = "test";',
            '// standalone comment',
            '// linked comment',
            'const bbb = "test";',
        }))
    end)
end)
