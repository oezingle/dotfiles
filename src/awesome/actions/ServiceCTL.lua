local Action     = require("src.util.Action")
local Service    = require("src.util.Service")
local includes   = require("src.polyfill.list.includes")

-- TODO FIXME finish typed for this, add argument types

-- TODO FIXME add tail

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
            " - enable <service>",
            " - disable <service>",
            " - tail <service>",
            " - status [service]"
        }, "\n")
    end

    if not includes({ "start", "stop", "restart", "enable", "disable", "tail", "status" }, method) then
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

-- TODO attach a logger to Service that clones logs to client 
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
        local fmt = "%s\t%s\t%s"

        local lines = {
            string.format(fmt, "NAME\t", "STATUS", "ENABLED")
        }

        local has_name = name and #name ~= 0

        if name and not Service.by_name(name) then            
            return
        end

        for name, service in pairs(has_name and { [name] = Service.names[name] } or Service.names) do
            local name_fmt = #name <= 8 and name .. "\t" or name    

            local line = string.format(fmt, name_fmt, service.status, Service.enabled:has(name))

            table.insert(lines, line)
        end

        self.log.info(table.concat(lines, "\n"))
    else
        name = name --[[ @as string ]]

        -- TODO export these to a method,
        -- Promise.resolve(that method)
        --      :after(function (ok) if not ok then error() end)
        --      :after(<success message>)
        --      :catch(<failure message>)

        if method == "start" then
            Service.start(name)
        elseif method == "stop" then
            Service.stop(name)
        elseif method == "restart" then
            Service.restart(name)
        elseif method == "enable" then
            Service.enable(name)
        elseif method == "disable" then
            Service.disable(name)
        elseif method == "tail" then
            self.log.error("Tail functionality has not been implemented yet.")

            return
        end
    end
end

return ServiceCTL
