local keyboard = require("src.cli.keyboard")

local dbus     = require("src.util.lgi.dbus")
local GVariant = require("src.util.lgi.GVariant")

local lgi      = require("lgi")
local GLib     = lgi.GLib

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

    local function call_command(command)
        if #command == 0 then
            return
        end

        local variant = GVariant("(s)", { command })

        proxy.method.SendCommand(variant)
    end

    local main_loop

    local thread = GThread("signal", function()
        proxy.connect_signal("Print", function(params)
            print(params)
        end)

        main_loop = GLib.MainLoop(nil, false)

        main_loop:run()
    end)

    local ok, err = pcall(function ()
        keyboard.prompt(call_command)
    end)

    if not ok then
        print(err)
    end

    thread:join()
end

local function main()
    loop()
end

main()
