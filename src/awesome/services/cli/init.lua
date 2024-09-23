
local Service          = require("src.util.Service")
local proxy_info       = require("src.cli.proxy_info")
local get_wm_interface = require("src.awesome.services.cli.get_wm_interface")
local time             = require("src.util.time")
local Gio              = lgi.Gio
local GObject          = lgi.GObject
local GVariant         = require("src.util.lgi.GVariant")
local Promise          = require("src.polyfill.Promise")
local map              = require("src.polyfill.list.map")
local timer_add        = require("src.util.timer.timer_add")

-- TODO FIXME leaks ~1KiB per call

---@alias Zingle.Awesome.Service.CLIServer.DBusMethod fun(self: self, client_name: string, args: LGI.GLib.GVariant): LGI.GLib.GVariant?

--[[
    https://stackoverflow.com/questions/58699363/tracking-dbus-connection-between-server-client

    Note to self about using signals for client return values

        I googled around for a way to send a method, not signal, back to a
    client and it's too much work for the low-stakes security scenario there is
    here. This is a command line for a window manager, not the effiel tower. The
    session bus protects from any interuser snooping ( assuming no sudoer uses
    su ) but hypothetically a user could look at the messages sent to another
    instance of the prompt in their own userspace. Who cares?
]]

---@class Zingle.Awesome.Service.CLIServer : Zingle.Awesome.Service
---@field clients table<string, { lines: number, cols: number, color: boolean, logger: Log, last_ping: number }>
local cli_server = Service.create({
    name = "cli"
})

-- register dbus methods
require("src.awesome.services.cli.dbus_method")(cli_server)

function cli_server:start()
    self.bus_owner_id = 0
    self.bus_object_id = 0

    self.clients = {}

    if not self.timer then
        self.timer = timer_add({
            timeout = 30,
            callback = function()
                self:forget_dead()
            end
        })
    end

    self.timer:start()

    self:own_bus()
end

--- Drop dead clients
function cli_server:forget_dead()
    for client_id, info in pairs(self.clients) do
        if info.last_ping + time():minutes(30):toSeconds() <= os.time() then
            self.log.info(string.format("Forgetting client %s", client_id))

            self.clients[client_id] = nil
        end
    end
end

function cli_server:stop()
    self.timer:stop()

    self:disown()
end

function cli_server:disown()
    if self.bus_object_id ~= 0 then
        self.connection:unregister_object(self.bus_object_id)

        self.bus_object_id = 0
    end

    -- https://docs.gtk.org/gio/func.bus_own_name.html#return-value
    if self.bus_owner_id ~= 0 then
        Gio.bus_unown_name(self.bus_owner_id)

        self.bus_owner_id = 0
    end
end

---@param client_name any
---@param level Logger.Level
---@param ... string
function cli_server:client_log(client_name, level, ...)
    local message = table.concat(map(table.pack(...), function(item)
        return tostring(item)
    end), "\t")

    local variant = GVariant("(sss)", { client_name, level, message })

    self.connection:emit_signal(
        nil,
        proxy_info.wm.path,
        proxy_info.wm.interface,
        "log",
        variant
    )
end

---@param client string
---@return Log
function cli_server:get_connection_logger(client)
    local logger = setmetatable({}, {
        __index = function(_, name)
            if name ~= "color" and name ~= "level" then
                local level = name

                return function(...)
                    self.log[level](client, ...)

                    self:client_log(client, level, ...)
                end
            end
        end
    })

    return logger
end

---@param client_name string
function cli_server:ping_client(client_name)
    local client = self.clients[client_name]

    if not client then
        return
    end

    client.last_ping = os.time()
end

--[[
    connection: GDBusConnection,
    client: string,
    path: string,
    interface: string,
    method: string,
    args: GVariant,
    invocation: GDBusMethodInvocation
]]
function cli_server:on_invocation(_, client, _, _, method_name, args, invocation)
    self.log.info(string.format("[%s] %s", client, method_name))

    if not self.clients[client] then
        ---@diagnostic disable-next-line:undefined-field
        self:dbus_method_set_info(client, {})
    end

    local method = self["dbus_method_" .. method_name]

    collectgarbage("step")

    if method then
        Promise.resolve(method(self, client, args))
            :after(function(ret)
                invocation:return_value(ret)

                self.log.debug("Method returned")
            end)
    else
        self.log.error(string.format("No method handler found for %q", method_name))
    end
end

-- function cli_server:on_bus_acquired(connection, name, user_data)
--
-- end

function cli_server:on_name_acquired(connection, name, user_data)
    self.log.info("Acquired DBus name")

    self.connection = connection

    -- TODO unregister on name lost?
    self.bus_object_id = connection:register_object(
        proxy_info.wm.path,
        get_wm_interface(),
        GObject.Closure(function(...)
            self:on_invocation(...)
        end)
    )
end

function cli_server:on_name_lost(connection, name, user_data)
    self.log.fatal(string.format("Killing CLI server: %s",
        -- https://docs.gtk.org/gio/func.bus_own_name.html#description
        connection == nil and "Unable to connect to DBus" or "Unable to obtain name on DBus"))

    local ok, err = pcall(self.stop, self)

    if not ok then
        self.log.error(string.format("Error while killing: %q", err))
    end

    self.status = Service.statuses.ERROR
end

function cli_server:own_bus()
    self.bus_owner_id = Gio.bus_own_name(
        Gio.BusType.SESSION,
        proxy_info.wm.service,
        Gio.BusNameOwnerFlags.NONE,
        -- handle_bus_acquired
        GObject.Closure(function(...)
            -- self:on_bus_acquired(...)
        end),
        -- handle_name_acquired
        GObject.Closure(function(...)
            self:on_name_acquired(...)
        end),
        -- handle_name_lost
        GObject.Closure(function(...)
            self:on_name_lost(...)
        end),
        nil, -- user_data
        nil  -- user_data_free_func
    )
end

cli_server:register()

return cli_server
