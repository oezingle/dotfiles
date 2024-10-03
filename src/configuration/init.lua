
local Configuration = require("src.configuration.Configuration")
local default = require("src.configuration.section.default")

local LuaHotConfigurationProvider = require("src.configuration.provider.LuaHot")
local LuaConfigurationProvider = require("src.configuration.provider.Lua")

local providers = {
    LuaHotConfigurationProvider,
    LuaConfigurationProvider
}

local config = Configuration(default, providers, true)

-- TODO FIXME maybe don't do this until rc.lua calls for it - allows setting up
-- loading before wait, and allows preload scripts TODO  - busted entrypoint
-- could load
config:create_provider()

return config
