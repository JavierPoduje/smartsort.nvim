local FileManager = require('file_manager')
local Region = require("region")
local SinglelineSorter = require('singleline_sorter')
local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("single line sort", function()
    it("should actually sort. like fr", function()
        local mock = typescript_mocks.single_line_sorter_mock
        utils.setup(mock.content, "typescript")
        local raw_str = FileManager.get_line(mock.region)
        local sorted_line = SinglelineSorter.new(","):sort(raw_str)
        equal(" aa, bb, cc, dd, hola ", sorted_line)
    end)

    it("shouldn't consider separator when is inside string", function()
        local mock = typescript_mocks.single_line_sorter_mock
        utils.setup(mock.content, "typescript")
        local raw_str = FileManager.get_line(Region.new(3, 17, 3, 46))
        local sorted_line = SinglelineSorter.new("|"):sort(raw_str)
        equal(' "bye" | "hi |" | "| goodbye";', sorted_line)
    end)

    it("should sort by spaces", function()
        local mock = typescript_mocks.single_line_spaces
        utils.setup(mock.content, "typescript")
        local raw_str = FileManager.get_line(mock.region)
        local sorted_line = SinglelineSorter.new("space"):sort(raw_str)
        equal(" aa bb cc dd hola ", sorted_line)
    end)
end)
