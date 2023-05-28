
local test = require("lib.test")

local subscription = require("src.util.wallpaper.subscription")
local wallpaper = require("src.util.wallpaper")
local hash = require("src.util.wallpaper.hash")

local fs = require("src.util.fs")
local Promise = require("src.util.Promise")

test.suite("wallpaper.subscription", 
    test.test(function ()
        local sub = subscription()
            :init(nil, 640, 480, false, nil)

        local walls = Promise.await(sub:generate())

        for identifier in pairs(wallpaper.config.table) do
            local key = hash(identifier)

            for _, wall in ipairs(walls) do
                ---@type string
                local path = wall[1]

                local path_match = path:match(fs.directories.wallpaper .. key)

                if path_match then
                    goto continue
                end
            end
                
            error(string.format("no path found for identifier %s, hashed to %s", tostring(identifier), key))

            ::continue::
        end
    end, "all paths generated"),
    test.test(function ()
        local paths = {}

        local sub = subscription()
            :init(function (path)
                table.insert(paths, path)
            end, 640, 480, false, nil)

        -- assures all values in paths are created, 
        -- though has the non-atomic side effect of 
        -- adding another copy of the generated path to paths.
        -- FOR SHAME!
        Promise.await(sub:generate())

        local one_by_one = paths[1]

        assert(one_by_one == fs.directories.assets .. "solid.png")
    end, "solid.png by default")
)