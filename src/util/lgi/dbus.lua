-- Quick DBus helper methods

local pack = require("src.agnostic.version.pack")
local unpack = require("src.agnostic.version.unpack")
local native_error = require("src.util.lgi.native_error")

local class = require("lib.30log")
local Promise = require("src.util.Promise")

-- TODO SmartTable.method_async - abusing the AwesomeWM mainloop does not fly!

-- TODO signals seem to not work

-- TODO lua types -> GVariant automatically?

local lgi = require("lgi")

local Gio = lgi.Gio

local dbus = {}

------------------------------- Type Definitions -------------------------------

---@alias GVariant unknown
---@alias GDBusConnection unknown

---@class SmartProxy a GDBusProxy in a more lua-friendly package
---@field method table<string, unknown> a virtual table for the methods exposed by the Proxy's interface (and ones that aren't)
---@field property { get: fun(name: string): GVariant, set: fun(name: string, value: GVariant): nil } get or set properties
---@field connect_signal fun(name: string, fn: fun(parameters: GVariant, sender_name: string): nil): nil connect dbus signals
---@field disconnect_signal fun(name: string, fn: fun(parameters: GVariant, sender_name: string): nil): nil disconnect dbus signals
---@field raw fun(): unknown get the raw GDBusProxy

--------------------------------------------------------------------------------

--- Get the Gio.BusType.SESSION or Gio.BusType.SYSTEM DBus
---@param bus_type "SESSION"|"SYSTEM"|number|nil
---@return GDBusConnection GDBusConnection
function dbus.get_bus(bus_type)
    if type(bus_type) == "nil" then
        bus_type = Gio.BusType.SESSION
    elseif bus_type == "SESSION" then
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
---@param connection GDBusConnection GDBusConnection to uses
---@param service string dbus service string
---@param path string dbus path string
---@param interface string dbus interface to employ over said path
dbus.new_proxy_with_connection = function(connection, service, path, interface)
    return native_error(
        Gio.DBusProxy.new_sync,
        connection,
        {},
        nil,
        service,
        path,
        interface,
        nil,
        nil
    )
end

--- Construct a SmartProxy
---@param ... any Args for dbus.new_proxy or dbus.new_proxy_with_connection
---@return SmartProxy SmartProxy
function dbus.new_smart_proxy(...)
    local args = pack(...)

    local proxy
    if #args > 3 then
        proxy = dbus.new_proxy_with_connection(unpack(...))
    else
        proxy = dbus.new_proxy(...)
    end

    return dbus.smart_proxy(proxy)
end

--- Turn a DBusProxy into a SmartProxy
---@return SmartProxy SmartProxy
function dbus.smart_proxy(proxy)
    -- TODO __close event for cleanup?
    -- http://lua-users.org/wiki/MetatableEvents

    local signal_handlers = {}

    -- untested signal handler
    -- https://docs.gtk.org/gio/signal.DBusProxy.g-signal.html
    -- https://github.com/lgi-devs/lgi/blob/master/docs/guide.md#34-signals
    
    --[[
        proxy['on_g-signal'] = function(self, sender_name, signal_name, parameters)
        print("signal recieved")
        
        -- should always be true but checking is good
        if self == proxy then
            local handlers = signal_handlers[signal_name]

            if handlers then
                for _, fn in ipairs(handlers) do
                    -- I have a hard time believing i will ever use sender_name, so I reversed args
                    fn(parameters, sender_name)
                end
            end
        end
    end
    ]]

    return {
        method = setmetatable({}, {
            __index = function(_, key)
                ---@param variant GVariant gvariant argument value
                return function(variant)
                    return native_error(
                        proxy.call_sync,
                        proxy,
                        key,
                        variant,
                        {},
                        -1,
                        nil,
                        nil
                    )
                end
            end
        }),
        property = {
            get = function(name)
                return proxy:get_cached_property(name)
            end,
            ---@param name string name of the property
            ---@param value GVariant gvariant value for the property
            set = function(name, value)
                return proxy:set(name, value)
            end,
        },
        prop = setmetatable({}, {
            __index = function(_, name)
                return proxy:get_cached_property(name)
            end,
            __newindex = function(_, name, value)
                return proxy:set(name, value)
            end
        }),
        ---@param name string signal name
        ---@param fn fun(parameters: GVariant, sender: string): nil signal recieved callback
        connect_signal = function(name, fn)            
            --[[
                self: GDBusProxy
                sender: string
                name: string
                parameters: GVariant
            ]]
            proxy["on_g-signal"].connect(name, function (_, sender, _, parameters)
                fn(parameters, sender)
            end)
        end,

        raw = function ()
            return proxy
        end
    }
end

---@class DBus.SmartProxy2 : LogBaseFunctions
---@field method table<string, fun(variant: GVariant): Promise<GVariant>>
---@field method_sync table<string, fun(variant: GVariant): Promise<GVariant>>
local smart_proxy_2 = class("SmartProxy")

function smart_proxy_2:init(proxy)
    self.proxy = proxy

    ---@type table<string, fun(variant: GVariant): Promise<GVariant>>
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
    ---@type table<string, fun(variant: GVariant): GVariant>
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
---@return GVariant
function smart_proxy_2:get_property(name)
    return self.proxy:get_cached_property(name)
end

---@param name string
---@param value GVariant
function smart_proxy_2:set_property(name, value)
    return self.proxy:set(name, value)
end

---@param name string
---@param variant GVariant gvariant argument value
---@return GVariant
function smart_proxy_2:call_method_sync(name, variant)
    return native_error(
        self.proxy.call_sync,
        self.proxy,
        name,
        variant,
        {},
        -1,
        nil,
        nil
    )
end


-- TODO untested
---@param name string
---@param variant GVariant gvariant argument value
---@return Promise<GVariant>
function smart_proxy_2:call_method(name, variant)
    return Promise(function (res, rej)
        local _, err = self.proxy:call(
            name, variant, {}, -1, nil, res
        )

        if err then
            rej(err)
        end
    end)
end

---@param name string signal name
---@param fn fun(parameters: GVariant, sender: string): nil signal recieved callback
function smart_proxy_2:connect_signal(name, fn)
    self.proxy["on_g-signal"].connect(name, function (_, sender, _, parameters)
        fn(parameters, sender)
    end)
end

---@param service string
---@param path string
---@param interface string
---@param connection string|GDBusConnection|nil
---@return DBus.SmartProxy2
function smart_proxy_2.create(service, path, interface, connection)
    if type(connection) == "string" then
        connection = dbus.get_bus(connection)
    end

    connection = connection or dbus.get_bus()

    local proxy = dbus.new_proxy_with_connection(connection, service, path, interface)

    return smart_proxy_2(proxy)
end 

dbus.smart_proxy_2 = smart_proxy_2


return dbus
