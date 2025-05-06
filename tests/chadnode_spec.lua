local Chadnodes = require("treesitter.chadnodes")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal

describe("chadnode", function()
    it("chadnodes can have comments", function()
        local mock = typescript_mocks.node_with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local comment_cnode = chadnodes:node_by_idx(1)
        local cnode = chadnodes:node_by_idx(2)

        equal(cnode == nil, false)
        equal(comment_cnode == nil, false)

        --- @diagnostic disable-next-line: need-check-nil, param-type-mismatch
        cnode:set_previous(comment_cnode)
        equal(
            true,
            vim.deep_equal(
            --- @diagnostic disable-next-line: need-check-nil
                cnode:to_string_preserve_indent(bufnr, 0),
                '/**\n * This is a comment\n */\nconst foo = () => {\n  console.log(\"foo\");\n};'
            )
        )
    end)

    describe("to_string_preserve_indent", function()
        it("respect the identation of the content of block", function()
            local mock = typescript_mocks.without_gap
            local bufnr, parser = utils.setup(mock.content, "typescript")
            local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            local cnode = chadnodes:node_by_idx(1)

            equal(cnode == nil, false)

            equal(
                true,
                vim.deep_equal(
                --- @diagnostic disable-next-line: need-check-nil
                    cnode:to_string_preserve_indent(bufnr, 3),
                    "const foo = () => {\n  console.log(\"foo\");\n};"
                )
            )
        end)

        it("respect the identation of the line in which the block has to be inserted", function()
            local mock = typescript_mocks.without_gap
            local bufnr, parser = utils.setup(mock.content, "typescript")
            local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            local cnode = chadnodes:node_by_idx(1)

            equal(cnode == nil, false)

            equal(
                true,
                vim.deep_equal(
                --- @diagnostic disable-next-line: need-check-nil
                    cnode:to_string_preserve_indent(bufnr, 4),
                    "  const foo = () => {\n    console.log(\"foo\");\n  };"
                )
            )
        end)
    end)

    describe("gap", function()
        it("should detect 0 line", function()
            local mock = typescript_mocks.without_gap
            local bufnr, parser = utils.setup(mock.content, "typescript")
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
            local bufnr, parser = utils.setup(mock.content, "typescript")
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
            local bufnr, parser = utils.setup(mock.content, "typescript")
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
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local chadnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        --- @type string[]
        local chadnode_idxs = {}
        for _, chadnode in ipairs(chadnodes:get()) do
            table.insert(chadnode_idxs, chadnode:get_sortable_idx())
        end

        truthy(vim.deep_equal(chadnode_idxs, { "foo", "bar" }))
    end)
end)
