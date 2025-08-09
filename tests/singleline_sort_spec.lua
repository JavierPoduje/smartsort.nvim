local typescript_mocks = require("tests.mocks.typescript")
local utils = require("tests.utils")
local SinglelineSorter = require('singleline_sorter')
local FileManager = require('file_manager')

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-field
local equal = assert.are.equal
--- @diagnostic disable-next-line: undefined-global
local it = it

describe("single line sort", function()
    it("can actually sort", function()
        local mock = typescript_mocks.single_line_sorter_mock
        local bufnr, parser = utils.setup(mock.content, "typescript")
        local raw_str = FileManager.get_line(mock.region)
        local sorted_line = SinglelineSorter.new(","):sort(raw_str)

        equal(" aa, bb, cc, dd, hola ", sorted_line)
    end)
end)
