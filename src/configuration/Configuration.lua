local tempstate    = require("src.state.temp")
local Promise      = require("src.polyfill.Promise")
local promise_iter = require("src.util.promise_iter")

---@class Zingle.Awesome.ConfigurationInfo
---@field configuration Zingle.Awesome.Config.Section.Default
---@field tempstate Zingle.Awesome.Tempstate
---@field package Zingle.Awesome.PackageLib
---@field save_state any


---@alias Zingle.Awesome.ConfigurationChangeHandler fun(config: Zingle.Awesome.ConfigurationInfo)


---@class Zingle.Awesome.Configuration : Log.BaseFunctions
---
---@field handles Zingle.Awesome.ConfigurationChangeHandler[]
---@field provider_classes Zingle.Awesome.ConfigurationProvider[]
---@field provider Zingle.Awesome.ConfigurationProvider
---@field configuration_object Zingle.Awesome.ConfigurationObject
---
---@operator call:Zingle.Awesome.Configuration
local Configuration = class("Zingle.Awesome.Configuration")

function Configuration:init(configuration_object, providers, noisy)
    self.provider_classes = providers

    self.configuration_object = configuration_object

    self.noisy = noisy or false

    self.handles = {}
end

--- Call this callback when the configuration changes
---@param handle Zingle.Awesome.ConfigurationChangeHandler
function Configuration:on_change(handle)
    table.insert(self.handles, handle)

    -- Provider has initialized already!
    if self.provider then
        local arg = self:get_handle_argument()

        handle(arg)
    end
end

function Configuration:get_handle_argument ()
    local arg = {
        configuration = self:bake_config(),
        tempstate = tempstate
    }

    return arg
end

function Configuration:bake_config()
    local configured = self.provider:get()

    return self.configuration_object:default(configured)
end

function Configuration:call_handles()
    local arg = self:get_handle_argument()

    for _, handle in ipairs(self.handles) do
        handle(arg)
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

                        if self.noisy then
                            log.debug(string.format("Using configuration provider %s", tostring(Provider)))
                        end

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
