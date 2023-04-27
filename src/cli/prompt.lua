local keyboard = require("src.cli.keyboard")

local dbus     = require("src.util.lgi.dbus")
local GVariant = require("src.util.lgi.GVariant")

local lgi      = require("lgi")
local Gio      = lgi.Gio
local GLib     = lgi.GLib
local GObject  = lgi.GObject

-- http://lua-users.org/lists/lua-l/2012-09/msg00360.html
---@param ... string
local function stty(...)
    local ok, p = pcall(io.popen, "stty -g")

    if not ok or not p then return nil end

    local state = p:read()
    p:close()


    if state and #... then
        os.execute(table.concat({ "stty", ... }, " "))
    end

    return state
end

local function loop()
    local proxy = dbus.new_smart_proxy(
        "org.awesomewm.cli",
        "/org/awesomewm/cli",
        "org.awesomewm.cli"
    )

    local conn = dbus.get_bus()

    conn:signal_subscribe(
        nil,
        nil,
        nil,
        nil,
        nil,
        Gio.DBusSignalFlags.NONE,
        function(...)
            print(...)
        end
    )

    local main_loop = GLib.MainLoop(nil, false)


    --[[
    -- this isn't portable if you port awesome to Windows
    local stdin = GLib.IOChannel.unix_new(0)
    stdin:set_encoding(nil)

    -- TODO per-character
    GLib.io_add_watch(stdin, GLib.PRIORITY_DEFAULT, GLib.IOCondition.IN, function(channel)
        local string_return = GLib.String("")

        channel:read_line_string(string_return, 0)

        ---@type string
        local cmd = string_return.str

        print(cmd)

        GLib.free(string_return)

        -- TODO io.write is borked
        io.stdout:write(" > ")

        return true
    end, nil)
    ]]
    --[[
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function ()
        keyboard.prompt(function (command)
            local variant = GVariant("(s)", { command })

            proxy.method.SendCommand(variant)
        end)

        return true
    end)
    ]]
    --[[
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function()
        print("hola")

        return true
    end)
    ]]

    -- TODO non blocking iput
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function()
        -- local char, other = io.stdin:read(1)

        -- stdin:close()
        -- stdin = io.popen(stdin_cat, "r")

        return true
    end)

    main_loop:run()
end

local function main()
    -- "-echo", "cbreak"

    local tty = stty("cbreak")

    local ok, err = pcall(loop)

    if not ok then
        -- restore tty state and then re-throw the error
        stty(tty)

        error(err)
    end

    stty(tty)
end

main()
