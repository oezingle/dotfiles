local config = require("config")
local fs     = require("src.util.fs")

local wallpaper_dir = fs.directories.wallpaper

-- Regenerate wallpapers if they've changed between awesome restarts
do
    local wallpaper = config.wallpaper

    local wallpapers = ""

    local wallpaper_is_list = config.wallpaper[1] ~= nil

    -- speed is all we really care about
    if wallpaper_is_list then
        for _, v in ipairs(wallpaper) do
            wallpapers = wallpapers .. v
        end
    else
        for k, v in pairs(wallpaper) do
            if k ~= "time" then
                wallpapers = wallpapers .. k .. v
            end
        end
    end

    local last_values_path = wallpaper_dir .. "last_values"

    if fs.read(last_values_path) ~= wallpapers then
        os.execute("rm -r " .. wallpaper_dir)

        fs.mkdir(wallpaper_dir)

        fs.write(last_values_path, wallpapers)
    end
end