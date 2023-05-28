
local test = require("lib.test")

local spairs = require("src.util.spairs")

test.suite("spairs",
    test.test(function ()
        local unorganized = { b = 2, a = 1, c = 3 }

        local keys = {}
        local values = {}

        for k, v in spairs(unorganized) do
            table.insert(keys, k)
            table.insert(values, v)
        end

        assert(table.concat(keys) == "abc")
        assert(table.concat(values) == "123")
    end, "keys & values")
)