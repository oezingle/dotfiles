
local is_light = require("src.util.wallpaper_old.is_light")
local test = require("lib.test")

test.suite("wallpaper.is_light", 
    test.test(function ()
        local light = nil

        is_light(function (res)
            light = res
        end)

        if not test.has_awesome() then
            assert(type(light) == "boolean")
        end
    end, "is_light")
)