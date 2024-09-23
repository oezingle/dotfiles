local split    = require("src.polyfill.string.split")
local Action   = require("src.util.Action")
local GVariant = require("src.util.lgi.GVariant")

---@param cli_server table<string, Zingle.Awesome.Service.CLIServer.DBusMethod> | Zingle.Awesome.Service.CLIServer
return function(cli_server)
    ---@type Zingle.Awesome.Service.CLIServer.DBusMethod
    function cli_server:dbus_method_disconnect(client_name)
        self.clients[client_name] = nil
    end

    ---@type Zingle.Awesome.Service.CLIServer.DBusMethod
    function cli_server:dbus_method_send_command(client_name, dbus_args)
        ---@type string
        local arg_str = dbus_args[1]

        local command_args = split(arg_str, "%s+")
        local command = table.remove(command_args, 1)

        local action = Action.commands[command]

        if not action then
            self:client_log(client_name, "error", string.format(
                "No action command by name %q", command
            ))

            return
        end

        local last_log = action.log

        action.log = self.clients[client_name].logger

        -- TODO FIXME promisify??
        action:call(table.unpack(command_args))
        
        action.log = last_log
    end

    ---@type Zingle.Awesome.Service.CLIServer.DBusMethod
    function cli_server:dbus_method_set_info(client_name, args)
        self.clients[client_name] = { last_ping = 0 }

        local client = self.clients[client_name]

        local names = { "lines", "cols", "color" }
        local types = { "number", "number", "boolean" }
        for i, v in ipairs(args) do
            local t = type(v)
            local name = names[i]

            if not t == types[i] then
                self.log.error(string.format(
                    "set_info recieved type %s for value %q when it expected type %s",
                    t, types[i]
                ))
            else
                client[name] = v
            end
        end

        client.logger = self:get_connection_logger(client_name)

        self:ping_client(client_name)

        return GVariant("(b)", { true })
    end
end
