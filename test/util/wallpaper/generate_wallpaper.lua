local generate_wallpaper = require("src.util.wallpaper.generate_wallpaper")
local test = require("lib.test")
local Promise = require("src.util.Promise")

local wallpaper = require("src.util.wallpaper.core")

--- Check that a proper path is returned
---@param p string|any
local function assert_good_path(p)
    assert(p)

    assert(type(p) == "string")

    assert(p:match("/") --[[ @as string ]])

    assert(p:sub(1, 1) --[[ @as string ]] == "/")
end 

test.suite("wallpaper.generate_wallpaper",
    test.test(function()
        local path = generate_wallpaper(wallpaper.current, 640, 480, false):await()

        assert_good_path(path)
    end, "640x480"),
    test.test(function()
        local path = generate_wallpaper(wallpaper.current, 640, 480, true):await()

        assert_good_path(path)
    end, "640x480 blur")
)
