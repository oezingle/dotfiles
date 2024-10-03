local Promise      = require("src.polyfill.Promise")
local promise_iter = require("src.util.promise_iter")

---@alias Zingle.Awesome.ConfigurationInfo Zingle.Awesome.Config.Section.Default

---@alias Zingle.Awesome.ConfigurationChangeHandler fun(config: Zingle.Awesome.ConfigurationInfo)

---@class Zingle.Awesome.ConfigurationChangeHandler.Identifier

---@class Zingle.Awesome.Configuration : Log.BaseFunctions
---
---@field handles Zingle.Awesome.ConfigurationChangeHandler[]
---@field provider_classes Zingle.Awesome.ConfigurationProvider[]
---@field provider Zingle.Awesome.ConfigurationProvider
---@field configuration_object Zingle.Awesome.ConfigurationObject
---
---@operator call:Zingle.Awesome.Configuration
local Configuration = class("Zingle.Awesome.Configuration")

function Configuration:init(configuration_object, providers)
    self.provider_classes = providers

    self.configuration_object = configuration_object

    self.handles = {}
end

--- Call this callback when the configuration changes
---@param handle Zingle.Awesome.ConfigurationChangeHandler
function Configuration:on_change(handle)
    ---@type Zingle.Awesome.ConfigurationChangeHandler.Identifier
    local identifier = {}
    
    self.handles[identifier] = handle

    -- Provider has initialized already!
    if self.provider then
        local config = self:bake_config()

        handle(config)
    end

    return identifier
end

---@param identifier Zingle.Awesome.ConfigurationChangeHandler.Identifier
function Configuration:unregister (identifier)
    self.handles[identifier] = nil
end

--- Merge the configuration from self.configuration_object with whatever keys
--- the provider has, resulting in a fully populated configuration
---@return Zingle.Awesome.ConfigurationInfo
function Configuration:bake_config()
    local configured = self.provider:get()

    return self.configuration_object:default(configured) --[[ @as Zingle.Awesome.ConfigurationInfo ]]
end

function Configuration:call_handles()
    local config = self:bake_config()

    for _, handle in pairs(self.handles) do
        handle(config)
    end
end

---@return Promise<nil>
function Configuration:create_provider()
    local call_handles = function()
        self:call_handles()
    end

    return promise_iter(function(control, _, Provider)
            return Promise.resolve(Provider.can_use())
                :after(function(can_use)
                    if can_use then
                        self.provider = Provider(call_handles)

                        log.debug(string.format("Using configuration provider %s", tostring(Provider)))

                        control['return'](true)
                    end
                end)
        end, ipairs(self.provider_classes))
        :after(function(provider_found)
            if provider_found then
                self:call_handles()
            else
                error("Unable to find a ConfigurationProvider")
            end
        end)
end

return Configuration
