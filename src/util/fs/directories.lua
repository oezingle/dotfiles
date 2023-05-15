-- dead simple

local config_dir = awesome and require("gears.filesystem").get_configuration_dir() or os.getenv("PWD") .. "/"

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