
local ConfigurationProvider = require("src.configuration.ConfigurationProvider")

---@class Zingle.Awesome.ConfigurationProvider.Lua : Zingle.Awesome.ConfigurationProvider
local LuaConfigurationProvider = ConfigurationProvider:extend("Zingle.Awesome.ConfigurationProvider.Lua")

function LuaConfigurationProvider.can_use ()
    return true
end

function LuaConfigurationProvider.get ()
    return require("config.awesome")
end

return LuaConfigurationProvider