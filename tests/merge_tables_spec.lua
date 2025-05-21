local merge_tables = require("funcs").merge_tables

--- @diagnostic disable-next-line: undefined-global
local describe = describe
--- @diagnostic disable-next-line: undefined-global
local it = it
--- @diagnostic disable-next-line: undefined-field
local truthy = assert.is.truthy

describe("merge_tables", function()
    it("should merge two list of numbers without modifying the original tables", function()
        local array1 = {
            ["1"] = 1,
            ["2"] = 2,
            ["3"] = 3,
        }
        local array2 = {
            ["4"] = 4,
            ["5"] = 5,
            ["6"] = 6,
        }

        local merged = merge_tables(array1, array2)

        truthy(vim.deep_equal(merged, {
            ["1"] = 1,
            ["2"] = 2,
            ["3"] = 3,
            ["4"] = 4,
            ["5"] = 5,
            ["6"] = 6,
        }))
        truthy(vim.deep_equal(array1, { ["1"] = 1, ["2"] = 2, ["3"] = 3 }))
        truthy(vim.deep_equal(array2, { ["4"] = 4, ["5"] = 5, ["6"] = 6 }))
    end)

    it("should be a `deep` merge", function()
        local config1 = {
            database = {
                host = "localhost",
                port = 5432
            },
            logging = {
                level = "info"
            }
        }

        local config2 = {
            database = {
                user = "admin",
                port = 8000 -- Overwrites 5432
            },
            cache = {
                enabled = true
            }
        }

        local config3 = {
            logging = {
                file = "app.log"
            },
            database = {
                password = "secret"
            }
        }

        local merged = merge_tables(config1, config2, config3)

        truthy(vim.deep_equal(merged, {
            database = {
                host = "localhost",
                user = "admin",
                port = 8000,
                password = "secret",

            },
            logging = {
                level = "info",
                file = "app.log"
            },
            cache = {
                enabled = true,
            },
        }))
    end)
end)
