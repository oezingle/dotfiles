local ConfigurationProvider       = require("src.configuration.ConfigurationProvider")
local get_meta_section            = require("src.configuration.get_meta_section")
local lfs                         = require("lfs")
local timer_add                   = require("src.util.timer.timer_add")

---@class Zingle.Awesome.ConfigurationProvider.Lua.Hot : Zingle.Awesome.ConfigurationProvider
---@operator call:Zingle.Awesome.ConfigurationProvider.Lua.Hot
local LuaHotConfigurationProvider = ConfigurationProvider:extend("Zingle.Awesome.ConfigurationProvider.Lua.Hot")

function LuaHotConfigurationProvider:init(trigger_reload)
    self.trigger_reload = trigger_reload

    local path = package.searchpath("config.awesome", package.path)
    if not path then
        error("Unable to find path for lua file \"config.awesome\"")
    end

    self.config_path = path

    self.last_mtime = self:mtime()

    self:register_timer()
end

function LuaHotConfigurationProvider.can_use()
    return get_meta_section()
        :after(function(meta)
            local config_section = meta.providers.LuaHot

            if config_section.enabled then
                return true
            end
        end)
end

function LuaHotConfigurationProvider:poll()
    log.debug("Polling config")

    local last_mtime = self.last_mtime

    local mtime = self:mtime()
    if mtime > last_mtime then
        self.last_mtime = mtime

        self.trigger_reload()
    end
end

function LuaHotConfigurationProvider:register_timer()
    return get_meta_section()
        :after(function(meta)
            local config_section = meta.providers.LuaHot

            return config_section.poll_rate
        end)
        :after(function (poll_rate)
            timer_add({
                timeout = poll_rate,
                callback = function ()
                    self:poll()
                end,
                autostart = true
            })                    
        end)
end

function LuaHotConfigurationProvider:mtime()
    return lfs.attributes(self.config_path).modification
end

function LuaHotConfigurationProvider:get()
    local file = io.open(self.config_path, "r")

    if not file then
        error(string.format("Unable to open file handle for %q", self.config_path))
    end

    local config = file:read("*a")

    local get_config, err = load(config, "config.awesome")

    if not get_config then
        error("Error while loading configuration file: " .. err)
    end

    return get_config()
end

return LuaHotConfigurationProvider
