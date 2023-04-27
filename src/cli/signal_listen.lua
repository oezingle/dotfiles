
local lgi       = require("lgi")
local Gio       = lgi.Gio
local GLib      = lgi.GLib

local dbus = require("src.util.lgi.dbus")

local conn = dbus.get_bus()

    conn:signal_subscribe(
        nil, 
        nil, 
        nil,
        nil,
        nil,
        Gio.DBusSignalFlags.NONE,
        function (...)
            print(...)
        end
    )

local main_loop = GLib.MainLoop(nil, false)
main_loop:run()
