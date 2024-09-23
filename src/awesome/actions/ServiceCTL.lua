local Action     = require("src.util.Action")
local Service    = require("src.util.Service")
local includes   = require("src.polyfill.list.includes")

---@class Zingle.Awesome.Action.Service : Zingle.Awesome.Action
local ServiceCTL = Action.create("service", {
    command = "service"
})

---@param method string?
---@return string?
function ServiceCTL:param_ok_method(method)
    if not method then
        return table.concat({
            "No command verb given. Possible choices:",
            " - start <service>",
            " - stop <service>",
            " - restart <service>",
            " - tail <service>",
            " - status [service]"
        }, "\n")
    end

    if not includes({ "start", "stop", "restart", "tail", "status" }, method) then
        return string.format("No known verb %q", method)
    end

    return nil
end

--- Check name parameter
---@param name string?
---@param allow_nil boolean
---@return string?
function ServiceCTL:param_ok_name(name, allow_nil)
    if allow_nil and name == nil then
        return nil
    end

    if not name or #name == 0 then
        return "The name of a service was not given"
    end

    if not Service.names[name] then
        return string.format("No known service %q", name)
    end

    return nil
end

---@param method string?
---@param name string?
function ServiceCTL:on_call(method, name)
    for _, err in ipairs({
        self:param_ok_method(method),
        -- name must be provided unless method is status
        self:param_ok_name(name, not not includes({
            "start", "stop", "restart", "tail"
        }, method))
    }) do
        -- TODO does not return?? bruh
        if err then
            self.log.error(err)

            return
        end
    end

    if method == "status" then
        if not name or #name == 0 then
            -- name not provided

            local fmt = "%s\t%s"

            local lines = {
                string.format(fmt, "NAME", "STATUS")
            }

            for _, service in pairs(Service.names) do
                local line = string.format(fmt, service.name, service.status)

                table.insert(lines, line)
            end

            self.log.info(table.concat(lines, "\n"))
        else

        end
    else
        name = name --[[ @as string ]]

        if method == "start" then
            Service.start_by_name(name)
        elseif method == "stop" then
            Service.stop(name)
        elseif method == "restart" then
            Service.restart(name)
        end
    end
end

return ServiceCTL
