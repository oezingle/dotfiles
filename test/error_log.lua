
local test = require("lib.test")

test.suite(
    "error_log",
    test.test(function ()
        require("src.error_log")
    end, "loads")
)