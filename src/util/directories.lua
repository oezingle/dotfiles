-- dead simple

local has_awesome = require("lib.test").has_awesome

local config_dir = os.getenv("PWD") .. "/"

if has_awesome() then
    local gfs = require("gears.filesystem")
    config_dir = gfs.get_configuration_dir()
end

local cache_dir = config_dir .. "cache/"

return {
    config = config_dir,
    cache = cache_dir
}
