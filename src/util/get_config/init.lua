local fs = require("src.util.fs")

local config_dir = fs.directories.config

-- local validate = require("src.util.get_config.validate")

---@module "_types.config_type"

---@return DotfileConfiguration
local function get_config()
    ---@type DotfileConfiguration|nil
    local config = fs.json.load(config_dir .. "config.json")
    
    if not config then
        ---@type DotfileConfiguration
        config = require("config")
    end

    ---@type DotfileConfiguration|nil
    local default_config = fs.json.load(config_dir .. "config.example.json")

    if not default_config then
        ---@type DotfileConfiguration
        default_config = require("config_example")
    end

    local conf = setmetatable(config, {
        __index = default_config
    })

    return conf
end

local config = get_config()

local function get_cached_config()
    return config
end

return get_cached_config