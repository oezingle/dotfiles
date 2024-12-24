local ModuleWatcher = require("src.util.HotReload.ModuleWatcher")

-- TODO create MockModuleWatcher in spec directory, and test this file 

---@alias Zingle.HotReload.ChangeHandler fun(modname: string, path: string)

-- TODO FIXME ModuleWatcher needs to have child modules

---@class Zingle.HotReload : Log.BaseFunctions
---@field protected watchers Zingle.HotReload.ModuleWatcher[]
---@field protected change_handlers Zingle.HotReload.ChangeHandler[]
---
local HotReload = class("Zingle.HotReload")

--[[
local hot_reload = {
    ---@type Zingle.HotReload.ModuleWatcher[]
    watchers = {},

    ---@type Zingle.HotReload.ChangeHandler[]
    change_handlers = {}
}
]]

local vanilla_require = require

---@param custom_require fun(modname: string): any
function HotReload:init(custom_require)
    self.watchers = {}

    self.change_handlers = {}

    self.vanilla_require = custom_require or vanilla_require
end

---@param modname string
function HotReload:require(modname)
    if not self.watchers[modname] then
        local watcher = ModuleWatcher(modname, function (...)            
            self:call_change(...)
        end,  self.vanilla_require)

        self.watchers[modname] = watcher            
    end

    return self.watchers[modname]:get_module()
end

---@param modname string
function HotReload:unrequire (modname) 
    self.watchers[modname] = nil
end

---@param watcher Zingle.HotReload.ModuleWatcher
function HotReload:call_change (watcher)
    local path = watcher.path
    local modname = watcher.modname

    for _, handler in ipairs(self.change_handlers) do
        handler(modname, path)
    end
end

---@param handler Zingle.HotReload.ChangeHandler
function HotReload:on_change (handler)
    table.insert(self.change_handlers, handler)
end

function HotReload:poll ()
    for _, watcher in pairs(self.watchers) do
        watcher:poll()
    end
end

function HotReload:register()
    require = function (...) 
        return self:require(...)
    end
end

return HotReload