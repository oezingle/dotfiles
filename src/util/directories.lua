-- dead simple

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local cache_dir = config_dir .. "cache/"

return {
    config = config_dir,
    cache = cache_dir
}