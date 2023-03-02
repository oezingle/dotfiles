
local fs = require("src.util.fs")

local config_dir = fs.directories.config

local function get_config ()
    local config = fs.json.load(config_dir .. "config.json")

    local default_config = fs.json.load(config_dir .. "config.default.json")

    return setmetatable(config, {
        __index = default_config
    })
end

local config = get_config()

local function get_cached_config ()
    return config
end

return get_cached_config()