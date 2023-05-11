local generate_wallpaper = require("src.util.wallpaper.generate_wallpaper")
local test = require("lib.test")
local Promise = require("src.util.Promise")

--- Check that a proper path is returned
---@param p string|any
local function assert_good_path(p)
    assert(p)

    assert(type(p) == "string")

    assert(p:match("/") --[[ @as string ]])

    assert(p:sub(1, 1) --[[ @as string ]] == "/")
end 

test.suite("generate_wallpaper",
    test.test(function()
        local path = Promise.await(generate_wallpaper(1, 640, 480, false))

        assert_good_path(path)
    end, "640x480"),
    test.test(function()
        local path = Promise.await(generate_wallpaper(1, 640, 480, true))

        assert_good_path(path)
    end, "640x480 blur")
)
