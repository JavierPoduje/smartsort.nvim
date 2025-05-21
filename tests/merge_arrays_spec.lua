local merge_arrays = require("funcs").merge_arrays

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("merge_arrays", function()
    it("should merge a list of three numbers without modifying the original tables", function()
        local list1 = { 1, 2, 3 }
        local list2 = { 4, 5, 6 }
        local list3 = { 4, 5, 6 }

        local merged = merge_arrays(list1, list2, list3)

        truthy(vim.deep_equal(merged, { 1, 2, 3, 4, 5, 6, 4, 5, 6 }))
        truthy(vim.deep_equal(list1, { 1, 2, 3 }))
        truthy(vim.deep_equal(list2, { 4, 5, 6 }))
        truthy(vim.deep_equal(list3, { 4, 5, 6 }))
    end)
end)
