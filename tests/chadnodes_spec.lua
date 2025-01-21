local Chadnodes = require("treesitter.chadnodes")
local Region = require("region")
local parsers = require("nvim-treesitter.parsers")
local typescript_mocks = require("tests.mocks.typescript")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy
--- @diagnostic disable-next-line: undefined-field
local same = assert.are.same

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

describe("chadnodes", function()
    describe("from_region", function()
        it("should recognize non-sortable nodes", function()
            local mock = typescript_mocks.with_comment
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

            truthy(vim.deep_equal(cnodes:debug(bufnr), {
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
                {
                    node = "// this is a comment",
                    sortable_idx = ""
                },
                {
                    node = 'function bar() {\n  console.log("bar");\n}',
                    sortable_idx = "bar"
                }
            }))
        end)

        it("should grab function comments", function ()
            local mock = typescript_mocks.commented_functions
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

            truthy(vim.deep_equal(cnodes:debug(bufnr), {
                {
                    node = "/**\n * This is a comment\n */",
                    sortable_idx = ""
                },
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
                {
                    node = "// this is a comment",
                    sortable_idx = ""
                },
                {
                    node = '// this comment "belongs" to the function',
                    sortable_idx = ""
                },
                {
                    node = 'function bar() {\n  console.log("bar");\n}',
                    sortable_idx = "bar"
                }
            }))
        end)

        it("shouldn't consider nodes outside region", function()
            local mock = typescript_mocks.simplest
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, Region.new(1, 1, 3, 1), parser)

            truthy(vim.deep_equal(cnodes:debug(bufnr), {
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
            }))
        end)
    end)

    describe("sort", function()
        it("should sort alphabetically", function()
            local mock = typescript_mocks.simplest
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

            truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
                {
                    node = 'function bar() {\n  console.log("bar");\n}',
                    sortable_idx = "bar"
                },
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
            }))
        end)

        it("should keep non-sortable nodes in their place", function()
            local mock = typescript_mocks.with_comment
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

            truthy(vim.deep_equal(cnodes:sort():debug(bufnr), {
                {
                    node = 'function bar() {\n  console.log("bar");\n}',
                    sortable_idx = "bar"
                },
                {
                    node = "// this is a comment",
                    sortable_idx = ""
                },
                {
                    node = 'const foo = () => {\n  console.log("foo");\n};',
                    sortable_idx = "foo"
                },
            }))
        end)
    end)

    it("get_sortable_nodes shouldn't consider non-sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = setup(mock.content)
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local sortables = cnodes:get_sortable_nodes()

        truthy(vim.deep_equal(Chadnodes.from_chadnodes(sortables):debug(bufnr), {
            {
                node = 'const foo = () => {\n  console.log("foo");\n};',
                sortable_idx = "foo"
            },
            {
                node = 'function bar() {\n  console.log("bar");\n}',
                sortable_idx = "bar"
            }
        }))
    end)

    it("get_non_sortable_nodes shouldn't consider sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = setup(mock.content)
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        local non_sortables = cnodes:get_non_sortable_nodes()

        truthy(vim.deep_equal(Chadnodes.from_chadnodes(non_sortables):debug(bufnr), {
            {
                node = "// this is a comment",
                sortable_idx = ""
            },
        }))
    end)

    it("cnode_is_sortable_by_idx recognizes sortable and non-sortable chadnodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = setup(mock.content)
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
        truthy(vim.deep_equal(cnodes:cnode_is_sortable_by_idx(), { true, false, true }))
    end)

    describe("gaps", function()
        it("should detect 'empty' gaps", function()
            local mock = typescript_mocks.without_gap
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            same(cnodes:gaps(), { 0 })
        end)

        it("should detect big gaps", function()
            local mock = typescript_mocks.with_bigger_gap
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            same(cnodes:gaps(), { 3 })
        end)

        it("should detect more than one gap", function()
            local mock = typescript_mocks.with_comment
            local bufnr, parser = setup(mock.content)
            local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)
            same(cnodes:gaps(), { 1, 1 })
        end)
    end)
end)
