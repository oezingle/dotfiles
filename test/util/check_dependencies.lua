
local test = require("lib.test")

local check_dependencies = require("src.util.check_dependencies")

test.suite(
    "check_dependencies",
    test.test(function ()
        local has_sh = false

        check_dependencies({ "sh" }, function ()
            has_sh = true
        end)

        -- check_dependencies works in async under AwesomeWM
        if not test.has_awesome() then
            assert(has_sh)            
        end
    end, "check sh")
)