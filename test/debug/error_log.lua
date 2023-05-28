
local test = require("lib.test")

test.suite(
    "error_log",
    test.awesome_only_test(function ()
        require("src.debug.error_log")
    end, "loads")
)