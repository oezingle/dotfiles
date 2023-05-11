
local get_path = require("src.util.wallpaper.get_path")

local test = require("lib.test")

local wallpaper = require("src.util.wallpaper.core")

--- Check that a proper path is returned
---@param p string|any
local function assert_good_path(p)
    assert(p)

    assert(type(p) == "string")

    assert(p:match("/") --[[ @as string ]])

    assert(p:sub(1, 1) --[[ @as string ]] == "/")
end 

test.suite("wallpaper.get_path", 
    test.test(function ()
        local path = get_path(wallpaper.current, 640, 480, false)

        assert_good_path(path)
    end, "640x480"),
    test.test(function ()
        local path = get_path(wallpaper.current, 640, 480, true)

        assert_good_path(path)
    end, "640x480 blur")
)