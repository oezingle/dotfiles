
local configuration = require("src.configuration")

---@class Zingle.Awesome.ConfigurationMixin
---@field use_config fun(self: self): self Register this instance to be aware of configuration changes
---@field useless_config fun(self: self): self Unregister this instance to be aware of configuration changes
---@field on_config_change fun(self: Zingle.Awesome.ConfigurationMixin, configuration: Zingle.Awesome.Config.Section.Default) React to configuration changes
---@field __config_unregister Zingle.Awesome.ConfigurationChangeHandler.Identifier
local ConfigurationMixin = {
    use_config = function (self)
        self.__config_unregister = configuration:on_change(function (config)
            self:on_config_change(config)
        end)

        return self
    end,
    on_config_change = function (self, config)

    end,
    useless_config = function (self)
        configuration:unregister(self.__config_unregister)

        return self
    end,
    ---@param self Zingle.Awesome.ConfigurationMixin
    __gc = function (self)
        self:useless_config()
    end
}

return ConfigurationMixin