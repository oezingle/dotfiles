local ModuleWatcher = require("src.util.hot_reload.ModuleWatcher")

-- TODO create MockModuleWatcher in spec directory, and test this file 

---@alias Zingle.HotReload.ChangeHandler fun(modname: string, path: string)

local hot_reload = {
    ---@type Zingle.HotReload.ModuleWatcher[]
    watchers = {},

    ---@type Zingle.HotReload.ChangeHandler[]
    change_handlers = {}
}

local vanilla_require = require

---@param modname string
function hot_reload.require(modname)
    local watcher = ModuleWatcher(modname, vanilla_require, hot_reload.call_change)

    table.insert(hot_reload.watchers, watcher)

    return watcher:get_module()
end

---@param watcher Zingle.HotReload.ModuleWatcher
function hot_reload.call_change (watcher)
    local path = watcher.path
    local modname = watcher.modname

    for _, handler in ipairs(hot_reload.change_handlers) do
        handler(modname, path)
    end
end

---@param handler Zingle.HotReload.ChangeHandler
function hot_reload.on_change (handler)
    table.insert(hot_reload.change_handlers, handler)
end

function hot_reload.poll ()
    for _, watcher in ipairs(hot_reload.watchers) do
        watcher:poll()
    end
end

function hot_reload.register()
    require = hot_reload.require
end

return hot_reload
