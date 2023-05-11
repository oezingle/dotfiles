local config = require("config")
local fs     = require("src.util.fs")

local wallpaper_dir = fs.directories.wallpaper

-- Regenerate wallpapers if they've changed between awesome restarts
do
    local wallpapers = config.wallpaper.list

    local wallpaper_string = ""

    local wallpaper_is_list = config.wallpaper.list[1] ~= nil

    -- speed is all we really care about
    if wallpaper_is_list then
        for _, v in ipairs(wallpapers) do
            wallpaper_string = wallpaper_string .. v
        end
    else
        for k, v in pairs(wallpapers) do
            if k ~= "time" then
                wallpaper_string = wallpaper_string .. k .. v
            end
        end
    end

    local last_values_path = wallpaper_dir .. "last_values"

    if fs.read(last_values_path) ~= wallpaper_string then
        os.execute("rm -r " .. wallpaper_dir)

        fs.mkdir(wallpaper_dir)

        fs.write(last_values_path, wallpaper_string)
    end
end