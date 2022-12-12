
local test = require("lib.test")

local check_dependencies = require("src.util.check_dependencies")

test.suite(
    "check_dependencies",
    test.test(function ()
        local has_sh = false

        check_dependencies({ "sh" }, function ()
            has_sh = true
        end)

        assert(has_sh)
    end, "check sh")
)