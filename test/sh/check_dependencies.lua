local test = require("lib.test")

local check_dependencies = require("src.sh.check_dependencies")

test.suite(
    "check_dependencies",
    test.test(function()
        local has_sh = false

        check_dependencies({ "sh" })
            :after(function(met)
                has_sh = met
            end):await()

        assert(has_sh)
    end, "check sh"),
    test.test(function()
        local has_dependencies = false

        check_dependencies({ "sh", "bash" })
            :after(function(met)
                has_dependencies = met
            end):await()

        assert(has_dependencies)
    end, "check sh and bash"),
    test.test(function()
        local has_dependencies

        check_dependencies({ "/does/not/exist", "/not/a/real/path", "sh" })
            :after(function(met)
                has_dependencies = met
            end):await()

        assert(not has_dependencies)
    end, "check nonexistent dependencies")
)
