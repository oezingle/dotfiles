
require("src.agnostic.jitfix")

local keyboard = require("src.cli.keyboard")

local get_commands = require("src.cli.get_commands")

local dbus     = require("src.util.lgi.dbus")
local GVariant = require("src.util.lgi.GVariant")

local GLib     = require("lgi").GLib

local proxy    = dbus.smart_proxy_2.create(
    "org.awesomewm.cli",
    "/org/awesomewm/cli",
    "org.awesomewm.cli"
)

local mainloop

local function exit()
    mainloop:quit()

    print("Goodbye!")
end

local function prompt()
    local ok, err = pcall(function()
        keyboard.readline(function(command)
            if #command == 0 then
                keyboard.restore_tty()

                return prompt()
            end

            if command == "exit" then
                exit()

                return
            elseif command == "help" then
                print("This utility exists to interface with AwesomeWM over DBus\n\nCommands:")

                local commands = {}

                for k, _ in pairs(get_commands()) do
                    table.insert(commands, k)
                end

                table.insert(commands, "help")
                table.insert(commands, "sh")

                print("", table.concat(commands, " "))

                print()

                keyboard.restore_tty()

                return prompt()
            end

            local variant = GVariant("(s)", { command })

            return proxy.method.SendCommand(variant)
                :after(function()
                    return prompt()
                end)
                :catch(function(err)
                    print("Error", err)

                    return prompt()
                end)
        end)
    end)

    if not ok then
        if tostring(err):match("interrupted!") then
            print()
            exit()
        else
            error(err)
        end
    end
end

local function main()
    mainloop = GLib.MainLoop(nil, false)

    proxy:connect_signal("Print", function(params)
        print(params[1])
    end)

    -- This runs once, once the loop is running
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function()
        prompt()
    end)

    mainloop:run()
end

main()
