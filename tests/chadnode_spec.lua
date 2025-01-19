local parsers = require("nvim-treesitter.parsers")
local typescript_mocks = require("tests.mocks.typescript")
local Chadnodes = require("treesitter.chadnodes")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal

--- @param buf_content string[]: the content of the buffer
--- @return number, vim.treesitter.LanguageTree
local setup = function(buf_content)
    vim.cmd(":new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_content)

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    -- set filetype
    local filetype = "typescript"
    vim.bo[bufnr].filetype = filetype

    -- set parser
    local parser = parsers.get_parser(bufnr, filetype)
    if not parser then
        error("Parser not available for filetype: " .. filetype)
    end
    parser:parse()

    return bufnr, parser
end

describe("chadnode", function()
    describe("gap", function()
        it("should detect 0 line", function()
            local mock = typescript_mocks.without_gap
            local bufnr, parser = setup(mock.content)
            local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            local cn1 = chadnodes:node_by_idx(1)
            local cn2 = chadnodes:node_by_idx(2)

            equal(cn1 == nil, false)
            equal(cn2 == nil, false)

            --- @diagnostic disable-next-line: need-check-nil, param-type-mismatch
            equal(cn1:gap(cn2), 0)
        end)

        it("should detect 1 line", function()
            local mock = typescript_mocks.simplest
            local bufnr, parser = setup(mock.content)
            local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            local cn1 = chadnodes:node_by_idx(1)
            local cn2 = chadnodes:node_by_idx(2)

            equal(cn1 == nil, false)
            equal(cn2 == nil, false)

            --- @diagnostic disable-next-line: need-check-nil, param-type-mismatch
            equal(cn1:gap(cn2), 1)
        end)

        it("should detect 3 line", function()
            local mock = typescript_mocks.with_bigger_gap
            local bufnr, parser = setup(mock.content)
            local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            local cn1 = chadnodes:node_by_idx(1)
            local cn2 = chadnodes:node_by_idx(2)

            equal(cn1 == nil, false)
            equal(cn2 == nil, false)

            --- @diagnostic disable-next-line: need-check-nil, param-type-mismatch
            equal(cn1:gap(cn2), 3)
        end)
    end)

    it("get_sortable_idx", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = setup(mock.content)
        local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        --- @type string[]
        local chadnode_idxs = {}
        for _, chadnode in ipairs(chadnodes:get()) do
            table.insert(chadnode_idxs, chadnode:get_sortable_idx())
        end

        truthy(vim.deep_equal(chadnode_idxs, { "foo", "bar" }))
    end)
end)
