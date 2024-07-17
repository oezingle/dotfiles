
local Configuration = require("src.configuration.Configuration")
local default = require("src.configuration.section.default")

local LuaHotConfigurationProvider = require("src.configuration.provider.LuaHot")
local LuaConfigurationProvider = require("src.configuration.provider.Lua")

local providers = {
    LuaHotConfigurationProvider,
    LuaConfigurationProvider
}

local config = Configuration(default, providers, true)

config:create_provider()

return config
