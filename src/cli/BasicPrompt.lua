local load_scripts = require("src.awesome.core.load_scripts")
local string_split = require("src.polyfill.string.split")
local Action       = require("src.util.Action")
local dbus         = require("src.util.lgi.dbus")
local SmartProxy   = dbus.SmartProxy
local MainLoop     = require("src.util.lgi.MainLoop")
local GVariant     = require("src.util.lgi.GVariant")
local timer_add    = require("src.util.timer.timer_add")
local proxy_info   = require("src.cli.proxy_info")
local tput         = require("src.util.spawn.tput")
local poll         = require("posix.poll").poll
local GLib         = lgi.GLib

-- TODO add a >
-- remove on client_log, reprint
-- https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html


require("src.cli.commands.help")
require("src.cli.commands.exit")

Action:set_logger({
    trace = print,
    debug = print,
    info = print,
    warn = print,
    error = print,
    fatal = print
})

---@class Zingle.Awesome.Core.CLI.BasicPrompt : Log.BaseFunctions
local BasicPrompt = class("Zingle.Awesome.Core.CLI.BasicPrompt")

function BasicPrompt:init()
    local connection = dbus.get_bus()

    self.dbus_id = connection['unique-name']

    self.proxy = SmartProxy.create(
        proxy_info.wm.service,
        proxy_info.wm.path,
        proxy_info.wm.interface,
        connection
    )

    self.loop = MainLoop()
end

local local_commands = {
    ["help"] = true,
    ["exit"] = true
}

function BasicPrompt:has_input()
    local fds = {
        [0] = {
            events = { IN = true },
            lua_file = io.stdin
        }
    }

    poll(fds, 10)

    for _, fd in pairs(fds) do
        if fd.revents and fd.revents.IN then
            fd.revents = nil

            return true
        end
    end

    return false
end

function BasicPrompt:on_connected()
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function()
        local ok, err = pcall(function()
            if self:has_input() then
                self:parse_once()
            end
        end)

        if not ok then
            local err = err --[[ @as string ]]

            if err:match("interrupted!") then
                self:quit()
            else
                self:quit(err)
            end
        end

        return true
    end)
end

function BasicPrompt:quit(reason)
    if reason ~= "" then
        print(reason or "Goodbye!")
    end

    self.proxy.method.disconnect()

    self.loop:quit()
end

function BasicPrompt:on_log(gvariant)
    local client_name, level, message = table.unpack(gvariant)

    if client_name == self.dbus_id then
        -- ignore level here
        print(message)

        -- log[level](message)
    end
end

function BasicPrompt:attempt_connect()
    load_scripts.poll()

    io.write("Connecting to DBus... ")

    local has_connection = false

    self.proxy:connect_signal("log", function(gvariant)
        self:on_log(gvariant)
    end)

    local lines = tput("lines")
    local cols = tput("cols")

    local term = os.getenv("TERM") or ""
    local colors = not not term:match("color")

    self.proxy.method.set_info(GVariant("(qqb)", { lines, cols, colors }))
        :after(function(res)
            assert(res, "Server did not respond")
            assert(res[1] == true, "Server responded incorrectly")

            print("OK")

            has_connection = true

            self:on_connected()
        end)
        :catch(function(arg)
            self:quit("Connection failed")

            print(arg)
        end)

    timer_add({
        timeout = 1,
        single_shot = true,
        autostart = true,
        callback = function()
            if not has_connection then
                self:quit("Timed out after 1s")
            end
        end
    })

    self.loop:run()
end

function BasicPrompt.run(self)
    if not self then
        local prompt = BasicPrompt()

        return prompt:run()
    end

    self:attempt_connect()
end

function BasicPrompt:parse_once()
    local commands = Action.commands

    local input = io.read()

    local args = string_split(input, "%s+")

    local command = table.remove(args, 1)

    if command == nil then
        return
    end

    local action = commands[command]

    if not action then
        print(string.format("No command %q", command))

        return
    end

    if local_commands[command] then
        action:call(args)
    else
        local variant = GVariant("(s)", { input })

        return self.proxy.method.send_command(variant)
            :after(function(arg)

            end)
            :catch(function(arg)
                -- TODO handle this
            end)
    end
end

return BasicPrompt
