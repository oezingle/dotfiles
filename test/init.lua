--[[
    Test handler injector for awesomewm signal / standalone tests
]]

-- TODO unload files once tests completed

local test = require("lib.test")

local function perform_tests()
    require("test.util.color.lighten")
    require("test.util.check_dependencies")
    require("test.util.get_wallpaper")
    require("test.util.Promise")
    require("test.util.time")
    require("test.util.uppercase_first_letters")
    require("test.util.wal")
end

if test.has_awesome() then
    awesome.connect_signal("awesome::dotfiles::test", function()
        perform_tests()
    end)
else
    perform_tests()
end

--[[
test.suite("example suite",
    test.assert(false, "falsey"),
    test.assert(true, "truthy"),
    test.test(function ()
        local a = nil

        a.b = 't'
    end, "fail throw"),
    test.test(function () end, "all good"),
    test.awesome_only_test(function () end, "awesome only")
)
]]

-- TODO auto require all files in this dir / subdirs
