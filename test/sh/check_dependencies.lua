local test = require("lib.test")

local check_dependencies = require("src.sh.check_dependencies")

test.suite(
    "check_dependencies",
    test.test(function()
        local has_sh = false

        check_dependencies({ "sh" })
            :after(function(met)
                has_sh = met
            end)

        -- check_dependencies works in async under AwesomeWM
        if not test.has_awesome() then
            assert(has_sh)
        end
    end, "check sh"),
    test.test(function()
        local has_dependencies = false

        check_dependencies({ "sh", "bash" })
            :after(function(met)
                has_dependencies = met
            end)

        -- check_dependencies works in async under AwesomeWM
        if not test.has_awesome() then
            assert(has_dependencies)
        end
    end, "check sh and bash"),
    test.test(function ()
        local has_dependencies
        
        check_dependencies({ "/does/not/exist", "/not/a/real/path", "sh" })
            :after(function (met)
                has_dependencies = met
            end)

        if not test.has_awesome() then
            assert(not has_dependencies)
        end
    end, "check nonexistent dependencies")
)
