local Chadnodes = require("chadnodes")
local Region = require("region")
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("chadnodes: from_region", function()
    it("should recognize non-sortable nodes", function()
        local mock = typescript_mocks.with_comment
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(cnodes:__tostring(), [[
            const foo = () => {
              console.log("foo");
            };
            // this is a comment
            function bar() {
              console.log("bar");
            }
        ]])
    end)

    it("should grab function comments", function()
        local mock = typescript_mocks.commented_functions
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(cnodes:__tostring(), [[
            /**
             * This is a comment
             */
            const foo = () => {
              console.log("foo");
            };
            // this is a comment
            // this comment "belongs" to the function
            function bar() {
              console.log("bar");
            }
        ]])
    end)

    it("shouldn't consider nodes outside region - start", function()
        local mock = typescript_mocks.simplest
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, Region.new(1, 1, 3, 1), parser)

        truthy(cnodes:__tostring(), [[
            const foo = () => {
              console.log("foo");
            };
        ]])
    end)

    it("shouldn't consider nodes outside region - end", function()
        local mock = typescript_mocks.middle_size
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local cnodes = Chadnodes.from_region(bufnr, mock.region, parser)

        truthy(cnodes:__tostring(), [[
            // this is a comment
            // comment attached to the function zit
            const zit = () => {
              console.log("zit");
            };
            // nested comment
            /**
             * This is a comment
             */
            function bar() {
              console.log("bar");
            }
        ]])
    end)
end)
