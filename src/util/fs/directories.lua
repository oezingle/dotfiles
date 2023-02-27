-- dead simple

local has_awesome = require("lib.test").has_awesome

local config_dir = os.getenv("PWD") .. "/"

if has_awesome() then
    local gfs = require("gears.filesystem")
    config_dir = gfs.get_configuration_dir()
end

local cache_dir = config_dir .. "cache/"

local wallpaper_dir = config_dir .. "cache/wallpaper/"

local icon_dir = config_dir .. "icon/"

local translation_dir = config_dir .. "translation/"

return {
    config = config_dir,
    cache = cache_dir,
    wallpaper = wallpaper_dir,
    icon = icon_dir,
    translation = translation_dir
}
