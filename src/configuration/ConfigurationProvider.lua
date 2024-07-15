---@nospec this is an abstract class

---@class Zingle.Awesome.ConfigurationProvider : Log.BaseFunctions
---@field can_use fun(): boolean | Promise<boolean>
---@field get fun (self: self): Zingle.Awesome.Configuration
---@field protected trigger_reload fun()
---@operator call:Zingle.Awesome.ConfigurationProvider
local ConfigurationProvider = class("Zingle.Awesome.ConfigurationProvider")

function ConfigurationProvider:init (trigger_reload)
    self.trigger_reload = trigger_reload
end

return ConfigurationProvider
