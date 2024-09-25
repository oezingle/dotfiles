local json = require("lib.json")
local fs = require("src.util.fs")
local includes = require("src.polyfill.list.includes")

--[[
---@class Zingle.PersistentStorage.Storage<T> : { __values: T }

---@class Zingle.PersistentStorage.Storage.Base<T> : Zingle.PersistentStorage.Storage<T>, {__path: string }
---@class Zingle.PersistentStorage.Storage.Subtable<T> : Zingle.PersistentStorage.Storage<T> | { __parent: Zingle.PersistentStorage.Storage.Any<table> }

---@alias Zingle.PersistentStorage.Storage.Any<T> Zingle.PersistentStorage.Storage.Base<T> | Zingle.PersistentStorage.Storage.Subtable<T>
]]

local PersistentStorage = {}

PersistentStorage.commit_on_change = not awesome

function PersistentStorage.on_change(table)
    if PersistentStorage.commit_on_change then
        PersistentStorage.commit(table)
    end
end

-- ---@param table Zingle.PersistentStorage.Storage.Any<table>
function PersistentStorage.commit(table)
    while table.__parent do
        table = table.__parent
    end

    local path = table.__path

    fs.mkdir_p(path)

    local str = json.encode(table.__values)

    fs.write(path, str)
end

PersistentStorage.realkeys = {"__path", "__parent", "__values"}

PersistentStorage.metatable = {
    __newindex = function(self, key, value)
        if includes(PersistentStorage.realkeys, key) then
            rawset(self, key, value)

            return
        end
        
        if type(value) == "table" then
            self.__values[key] = PersistentStorage.subtable(self, value)
        elseif includes({ "function", "thread", "userdata" }, type(value)) then
            log.error(string.format("PersistentStorage cannot contain objects of type %s", type(value)))

            return
        else
            self.__values[key] = value
        end

        PersistentStorage.on_change(self)
    end,
    __index = function(self, key)
        if includes(PersistentStorage.realkeys, key) then
            return rawget(self, key)
        end

        return self.__values[key]
    end,
    __ipairs = function(self)
        return ipairs(self.__values)
    end,
    __pairs = function (self)
        return pairs(self.__values)
    end,
    __name = "PersistentStorage"
}

function PersistentStorage.get_table(path, default)
    if fs.exists(path) then
        local content = fs.read(path)

        return { __path = path, __values = json.decode(content) }
    else
        return { __path = path, __values = default or {} }
    end
end

---@generic T : table
---@param path string
---@param default T?
---@return T
function PersistentStorage.create(path, default)
    local storage = setmetatable(PersistentStorage.get_table(path, default), PersistentStorage.metatable)

    if awesome then
        local commit_closure = function()
            PersistentStorage.commit(storage)
        end

        -- TODO FIXME test this!
        awesome.connect_signal("exit", commit_closure)
        awesome.connect_signal("debug::error", commit_closure)
    end

    return storage
end

function PersistentStorage.subtable(parent, table)
    table.__parent = parent

    return setmetatable({
        __parent = parent,
        __values = table
    }, PersistentStorage.metatable)
end

return PersistentStorage
