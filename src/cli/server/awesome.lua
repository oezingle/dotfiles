local pack         = require("src.agnostic.version.pack")

local envhacks     = require("src.agnostic.version.envhacks")
local interpret    = require("src.cli.server.interpret")

local bad_argparse = require("src.cli.bad_argparse")

local lgi          = require("lgi")
local Gio          = lgi.Gio
local GObject      = lgi.GObject

local GVariant     = require("src.util.lgi.GVariant")

local function on_bus_acquired(connection, name, user_data)
    local node_info = Gio.DBusNodeInfo.new_for_xml(
        [[
            <node>
                <interface name='org.awesomewm.cli'>
                    <method name="SendCommand">
                        <arg type='s' name='command' direction='in'/>
                    </method>

                    <signal name='Print'>
                        <arg type='s' name='output' />
                    </signal>
                </interface>
            </node>
        ]]
    )

    local function connection_print(...)
        local TAB = string.char(9)

        local args = pack(...)

        for i, arg in ipairs(args) do
            if type(arg) == "nil" then
                args[i] = ""
            end

            if type(arg) ~= "string" then
                args[i] = tostring(arg)
            end
        end

        local msg = table.concat(args, TAB)

        connection:emit_signal(
            nil,
            "/org/awesomewm/cli",
            "org.awesomewm.cli",
            "Print",
            GVariant("(s)", { msg })
        )
    end

    -- remap print() to work over D-Bus (this feels so fancy)
    local env = setmetatable({
        print = connection_print
    }, { __index = _G })

    envhacks.setfenv(interpret, env)

    bad_argparse.print = connection_print

    -- TODO throw errors man
    connection:register_object(
        "/org/awesomewm/cli",
        node_info.interfaces[1],
        --[[
            connection: GDBusConnection,
            client: string,
            path: string,
            interface: string,
            method: string,
            args: GVariant,
            invocation: GDBusMethodInvocation
        ]]
        GObject.Closure(function(connection, client, _, _, method, args, invocation)
            xpcall(
                function()
                    if not method == "SendCommand" then
                        return
                    end

                    local command = args[1]

                    interpret(command)
                end,
                function(err)
                    connection_print("Server Error:", debug.traceback(err))
                end
            )

            invocation:return_value(nil)
        end)
    )
end

local function create_cli_hooks()
    Gio.bus_own_name(
        Gio.BusType.SESSION,
        "org.awesomewm.cli",
        Gio.BusNameOwnerFlags.NONE,
        GObject.Closure(on_bus_acquired),
        nil,
        nil,
        nil,
        nil
    )
end

create_cli_hooks()
