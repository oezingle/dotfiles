local lfs = require("lfs")

---@class Zingle.HotReload.ModuleWatcher : Log.BaseFunctions
---@operator call:Zingle.HotReload.ModuleWatcher
---
---@field modname string
---@field require fun(modname: string): any, string
---@field call_change fun(module_watcher: self)
---
---@field path string
---@field hot boolean
---
---@field last_mtime number
---
local ModuleWatcher = class("Zingle.HotReload.ModuleWatcher")

---@param modname string
---@param call_change fun(module_watcher: self)
---@param custom_require? fun(modname: string): any, string
function ModuleWatcher:init(modname, call_change, custom_require)
    self.modname = modname

    self.call_change = call_change
    
    self.require = custom_require or require
end

local module_mock_mt = {
    -- TODO FIXME these guys are more complex... which table is t1, which is t2? hard to know.
    -- __unm = mt._unm,
    -- __add = mt.__add,
    -- __sub = mt.__sub,
    -- __mul = mt.__mul,
    -- __div = mt.__div,
    -- __idiv = mt.__idiv,
    -- __mod = mt.__mod,
    -- __pow = mt.__pow,
    -- __concat = mt.__concat,

    __call = function(t, ...)
        return t.__module(...)
    end,

    __index = function(t, key)
        return t.__module[key]
    end,
    -- TODO maybe track new indices?? reload will wipe these.
    __newindex = function(t, key, value)
        t.__module[key] = value
    end,

    __tostring = function(t)
        return tostring(t.__module)
    end,

    __len = function(t)
        return #t.__module
    end,

    __pairs = function(t)
        return pairs(t.__module)
    end,
    __ipairs = function(t)
        return ipairs(t.__module)
    end,

    __gc = function(t)
        local gc = (getmetatable(t.__module) or {}).__gc

        if gc then
            gc()
        end
    end,
}

---@generic T
---@param table { __module: `T` }
---@return T
function ModuleWatcher.mock_module(table)
    -- Throw an error just in case this happens during any interal use (test coverage, etc)
    assert(table.__module, "tables passed to mock_module must have a singular entry keyed by \"__module\"")

    return setmetatable(table, module_mock_mt)
end

function ModuleWatcher:get_module()
    local module, path = self:re_require()

    if not module or not path then
        -- TODO issue here.
        -- TODO maybe don't error?
        error(string.format("Unable to require module %q", self.modname))
    else
        -- TODO should path be dynamic?
        self.path = path
        self.last_mtime = self:mtime()

        if type(module) == "table" or type(module) == "function" then
            self.hot = true

            self.mock = self.mock or {}

            self.mock.__module = module

            self.mock_module(self.mock)

            return self.mock, path
        else
            self.hot = false

            log.warn(string.format("Module %q returns a primitive value and cannot be hot-reloaded", self.modname))

            return module, path
        end
    end
end

---@return string | nil, string | nil
function ModuleWatcher:re_require()
    --- Remove package from loaded
    package.loaded[self.modname] = nil

    --- Try requiring
    local ok, module, path = pcall(self.require, self.modname)

    if not ok then
        local err = module

        log.error(string.format("Unable to load module %q", self.modname))
        print(err)

        return nil, nil
    end

    return module, path
end

function ModuleWatcher:poll()
    local mtime = self:mtime()

    if mtime > self.last_mtime then
        if self.hot then
            log.info(string.format("Reloading module %q", self.modname))

            local new_module = self:re_require()

            setmetatable(self.mock, {})
            self.mock.__module = new_module
            self.mock_module(self.mock)

            self:call_change()
        else
            log.error(string.format("Cannot reload module %q, despite it changing.", self.modname))
        end

        self.last_mtime = mtime
    end
end

function ModuleWatcher:mtime()
    return lfs.attributes(self.path).modification
end

return ModuleWatcher
