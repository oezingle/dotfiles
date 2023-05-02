local keyboard = require("src.cli.keyboard")

local dbus     = require("src.util.lgi.dbus")
local GVariant = require("src.util.lgi.GVariant")

local lgi      = require("lgi")
local Gio      = lgi.Gio
local GLib     = lgi.GLib
local GObject  = lgi.GObject

local GThread  = GLib.Thread

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

-- TODO none of this shit works - use a lua binding for ncurses or Readline
-- TODO switch to C++? getch works in nodelay mode with ncurses, readline is native if able to use, GLib is native C
local function loop()
    local proxy = dbus.new_smart_proxy(
        "org.awesomewm.cli",
        "/org/awesomewm/cli",
        "org.awesomewm.cli"
    )

    proxy.connect_signal("Print", function (params)
        print(params[1])
    end)

    local function call_command(command)
        if #command == 0 then
            return
        end

        local variant = GVariant("(s)", { command })

        proxy.method.SendCommand(variant)
    end

    local thread = GThread("keyboard", function()
        keyboard.prompt(call_command)
    end)

    local main_loop = GLib.MainLoop(nil, false)

    main_loop:run()

    thread:exit()
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
