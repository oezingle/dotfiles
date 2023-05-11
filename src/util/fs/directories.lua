-- dead simple

local has_awesome = require("lib.test").has_awesome

local config_dir = os.getenv("PWD") .. "/"

if has_awesome() then
    local gfs = require("gears.filesystem")
    config_dir = gfs.get_configuration_dir()
end

local cache_dir = config_dir .. "cache/"

local wallpaper_dir = config_dir .. "cache/wallpaper/"

local asset_dir = config_dir .. "asset/"

local icon_dir = asset_dir .. "icon/"

local translation_dir = asset_dir .. "translation/"

local script_dir = config_dir .. "sh/"

local dirs = {
    config = config_dir,
    cache = cache_dir,
    wallpaper = wallpaper_dir,
    assets = asset_dir,
    icon = icon_dir,
    translation = translation_dir,
    script = script_dir
}

return dirs