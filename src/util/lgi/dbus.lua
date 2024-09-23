
local Promise = require("src.polyfill.Promise")
local lgi = require("lgi")

local Gio = lgi.Gio

local dbus = {}

------------------------------- Type Definitions -------------------------------

---@class LGI.Gio.GDBusConnection

--------------------------------------------------------------------------------

--- Get the Gio.BusType.SESSION or Gio.BusType.SYSTEM DBus
---@param bus_type "SESSION"|"SYSTEM"|number|nil
---@return LGI.Gio.GDBusConnection GDBusConnection
function dbus.get_bus(bus_type)
    local bus_type = bus_type or "SESSION"
    
    if bus_type == "SESSION" then
        bus_type = Gio.BusType.SESSION
    elseif bus_type == "SYSTEM" then
        bus_type = Gio.BusType.SYSTEM
    end

    return Gio.bus_get_sync(
        bus_type,
        nil,
        nil
    )
end

--- Get a dbus proxy from Gio
---@param service string dbus service string
---@param path string dbus path string
---@param interface string dbus interface to employ over said path
function dbus.new_proxy(service, path, interface)
    local conn = dbus.get_bus()

    return dbus.new_proxy_with_connection(conn, service, path, interface)
end

--- Get a dbus proxy from Gio while providing your own DBus connection
---@param connection LGI.Gio.GDBusConnection GDBusConnection to uses
---@param service string dbus service string
---@param path string dbus path string
---@param interface string dbus interface to employ over said path
dbus.new_proxy_with_connection = function(connection, service, path, interface)
    local ret, err = Gio.DBusProxy.new_sync(connection,
        {},
        nil,
        service,
        path,
        interface,
        nil,
        nil
    )

    if err then
        error(err)
    end

    return ret
end

---@class Zingle.DBus.SmartProxy : Log.BaseFunctions
---@field method table<string, fun(variant: LGI.GLib.GVariant?): Promise<LGI.GLib.GVariant>>
---@field method_sync table<string, fun(variant: LGI.GLib.GVariant?): Promise<LGI.GLib.GVariant>>
local SmartProxy = class("SmartProxy")

function SmartProxy:init(proxy, connection)
    self.proxy = proxy

    self.connection = connection

    ---@type table<string, fun(variant: LGI.GLib.GVariant?): Promise<LGI.GLib.GVariant>>
    self.method = setmetatable({}, {
        __call = function (_, name, variant)
            return self:call_method(name, variant)
        end,
        __index = function(_, key)
            return function (variant)
                return self:call_method(key, variant)
            end
        end
    })
    ---@type table<string, fun(variant: LGI.GLib.GVariant?): LGI.GLib.GVariant>
    self.method_sync = setmetatable({}, {
        __call = function (_, name, variant)
            return self:call_method_sync(name, variant)
        end,
        __index = function(_, key)
            return function (variant)
                return self:call_method_sync(key, variant)
            end
        end
    })
    
    self.property = setmetatable({}, {
        __index = function(_, name)
            return self:get_property(name)
        end,
        __newindex = function(_, name, value)
            return self:set_property(name, value)
        end
    })
end

---@param name string
---@return LGI.GLib.GVariant
function SmartProxy:get_property(name)
    return self.proxy:get_cached_property(name)
end

---@param name string
---@param value LGI.GLib.GVariant
function SmartProxy:set_property(name, value)
    return self.proxy:set(name, value)
end

---@param name string
---@param variant LGI.GLib.GVariant? gvariant argument value
---@return LGI.GLib.GVariant
function SmartProxy:call_method_sync(name, variant)
    local ret, err = self.proxy:call_sync(
        name,
        variant,
        {},
        -1,
        nil,
        nil
    )

    if err then
        error(err)
    end

    return ret
end


-- TODO untested
---@param name string
---@param variant LGI.GLib.GVariant? gvariant argument value
---@return Promise<LGI.GLib.GVariant>
function SmartProxy:call_method(name, variant)
    return Promise(function (res, rej)
        local _, err = self.proxy:call(
            name, variant, {}, -1, nil, function (proxy, task, data)
                local ret = self.proxy:call_finish(task)

                res(ret)
            end
        )

        if err then
            rej(err)
        end
    end)
end

---@param name string signal name
---@param fn fun(parameters: LGI.GLib.GVariant, sender: string): nil signal recieved callback
function SmartProxy:connect_signal(name, fn)
    self.proxy["on_g-signal"].connect(name, function (_, sender, _, parameters)
        fn(parameters, sender)
    end)
end

---@param service string
---@param path string
---@param interface string
---@param connection string|LGI.Gio.GDBusConnection|nil
---@return Zingle.DBus.SmartProxy
function SmartProxy.create(service, path, interface, connection)
    if type(connection) == "string" then
        connection = dbus.get_bus(connection)
    end

    connection = connection or dbus.get_bus()

    local proxy = dbus.new_proxy_with_connection(connection, service, path, interface)

    return SmartProxy(proxy, connection)
end 

dbus.SmartProxy = SmartProxy

return dbus
