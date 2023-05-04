local bad_argparse = require("src.cli.bad_argparse")
local services     = require("src.sh.service")

---@param status Service.Status
---@return string
local function translate_status(status)
    if status == services.status.RUNNING then
        return "RUNNING"
    elseif status == services.status.STARTED then
        return "STARTED"
    elseif status == services.status.STARTING then
        return "STARTING"
    elseif status == services.status.STOPPING then
        return "STOPPING"
    elseif status == services.status.STOPPED then
        return "STOPPED"
    elseif status == services.status.NOT_RUNNING then
        return "NOT_RUNNING"
    elseif status == services.status.ERROR then
        return "ERROR"
    elseif status == services.status.EXITED then
        return "EXITED (ok)"
    elseif status == nil then
        return "unknown"
    else
        return "Bad developer! Bad! Bad!"
    end
end

---@param service Service
local function conditionally_start(service)
    local status = service:get_info().status

    if status == services.status.ERROR or status == services.status.NOT_RUNNING or status == services.status.STOPPED then
        service:start()
    end
end

---@param name string
---@param callback fun(service: Service)
local function using_service(name, callback)
    local service = services.find(name)

    if not service then
        print(string.format("No service '%s'", name))

        return
    end

    callback(service)
end

local function main()
    local args = bad_argparse("sh", "manage awesome's running child processes")
        :add_argument("command", "one of: status, start, stop, restart")
        :add_argument("process", "the process to inspect, or * for all", "*")
        :parse(arg)

    if not args then
        return
    end

    ---@type "status"|"start"|"stop"|"restart"|string
    local command = args.arguments[1]

    local service_name = args.arguments[2]

    if command == "status" then
        if service_name == "*" then
            for _, service in ipairs(services.list) do
                local info = service:get_info()

                print(info.name, translate_status(info.status))
            end
        else
            using_service(service_name, function(service)
                local info = service:get_info()

                print(string.format(
                    [[%s - %s
          Status: %s
             PID: %d
         Depends: %s]],
                    info.name,
                    info.description,
                    translate_status(info.status),
                    info.pid,
                    #info.dependencies ~= 0 and table.concat(info.dependencies, ", ") or "None"
                ))
            end)
        end
    elseif command == "start" then
        if service_name == "*" then
            for _, service in ipairs(services.list) do
                conditionally_start(service)
            end
        else
            using_service(service_name, function (service)
                conditionally_start(service)
            end)
        end
    elseif command == "stop" then
        if service_name == "*" then
            for _, service in ipairs(services.list) do
                service:stop()
            end
        else
            using_service(service_name, function (service)
                service:stop()
            end)
        end
    elseif command == "restart" then
        if service_name == "*" then
            for _, service in ipairs(services.list) do
                service:stop()

                conditionally_start(service)
            end
        else
            using_service(service_name, function (service)
                service:stop()

                conditionally_start(service)
            end)
        end
    else
        print(string.format("Unknown command verb '%s'", command))
    end
end

main()
