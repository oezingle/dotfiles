
---@class Zingle.Set<T> : Log.BaseFunctions, { key_table: table<T, true>, keys: (fun(self: self): T[]), add: fun(self: self, key: T), remove: fun(self: self, key: T), has: (fun(self: self, key: T): boolean) }
---@field key_table table<any, true>
---@field add fun(self: self, key: any)
---@field remove fun(self: self, key: any)
---@field has fun(self: self, key: any): boolean
---@field clear fun(self: self)
---@field keys fun(self: self): any[]
---
---@operator call:Zingle.Set
local Set = class("Zingle.Set")

function Set:init (keys)
    self.key_table = keys or {}
end

function Set:keys ()
    local t = {}

    for key in pairs(self) do
        table.insert(t, key)
    end

    return t
end

---## ! About twice as slow as pairs !
function Set:__ipairs()
    return ipairs(self:keys())
end

function Set:__pairs()
    return pairs(self.key_table)
end

function Set:add (key)
    self.key_table[key] = true
end

function Set:remove(key)
    self.key_table[key] = nil
end

function Set:has(key)
    return self.key_table[key] or false
end

return Set