local interpret = require("src.cli.server.interpret")
local envhacks  = require("src.cli.server.envhacks")

local lgi       = require("lgi")
local Gio       = lgi.Gio
local GObject   = lgi.GObject
local GLib      = lgi.GLib

local GVariant = require("src.util.lgi.GVariant")

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
            if not method == "SendCommand" then
                return
            end

            local command = args[1]

            connection:emit_signal(
                nil,
                "/org/awesomewm/cli",
                "org.awesomewm.cli",
                "Print",
                GVariant("(s)", { "recv" })
            )

            --[[
            -- Literally the tab character
            local TAB = string.char(9)

            local env = envhacks.overwrite_globals({
                print = function(...)
                    io.write(table.concat(..., TAB), "\n")
                end
            })

            envhacks.in_env(env, function()
                interpret(command)
            end)
            ]]

            interpret(command)

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

    --[[
    local main_loop = GLib.MainLoop(nil, false)
    main_loop:run()
    ]]
end

create_cli_hooks()
