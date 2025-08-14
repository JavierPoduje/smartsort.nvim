local FileManager = require('file_manager')
local file_manager_mocks = require("tests/mocks/file_manager")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("FileManager", function()
    describe("get_region_indentation", function()
        it("handles one line with no indentation", function()
            local mock = file_manager_mocks.no_indentation
            local bufnr, _ = utils.setup(mock.content, mock.language)
            local identation = FileManager.get_region_indentation(bufnr, mock.region)
            equal(0, identation)
        end)

        it("handles one line with two spaces indentation", function()
            local mock = file_manager_mocks.two_spaces
            local bufnr, _ = utils.setup(mock.content, mock.language)
            local identation = FileManager.get_region_indentation(bufnr, mock.region)
            equal(2, identation)
        end)

        it("handles one line with four spaces indentation", function()
            local mock = file_manager_mocks.four_spaces
            local bufnr, _ = utils.setup(mock.content, mock.language)
            local identation = FileManager.get_region_indentation(bufnr, mock.region)
            equal(4, identation)
        end)

        it("handles one line with one tab indentation", function()
            local mock = file_manager_mocks.one_tab
            local bufnr, _ = utils.setup(mock.content, mock.language)
            local identation = FileManager.get_region_indentation(bufnr, mock.region)
            equal(1, identation)
        end)
    end)
end)
