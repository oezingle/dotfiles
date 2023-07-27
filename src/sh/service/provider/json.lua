local class                 = require("lib.30log")

local check_dependencies    = require("src.sh.check_dependencies")
local Promise               = require("src.util.Promise")
local awful                 = require("awful")

---@class JSONServiceProvider : Service, Log.BaseFunctions
---@operator call:JSONServiceProvider
local json_service_provider = class("JSONServiceProvider")

---@class JSONServiceTable
---@field exec string
---@field description string
---@field name string
---@field dependencies string[]
---@field kill boolean
---@field status Service.Status
---@field pid integer

local service_status        = require("src.sh.service.status")

---@param args { exec: string|string[], description: string?, dependencies: string|string[]|nil, kill: boolean? }
---@return JSONServiceTable
local function safe_service(args)
    local exec = args.exec

    if type(exec) == "table" then
        exec = table.concat(exec, "; ")
    end

    local description = args.description or "No description provided"

    local dependencies = args.dependencies or {}

    if type(dependencies) == "string" then
        dependencies = { dependencies }
    end

    local kill = args.kill or false

    -- local shell = args.shell or false

    return {
        exec         = exec,
        description  = description,
        dependencies = dependencies,
        kill         = kill,
        -- shell        = shell,
        status       = service_status.NOT_RUNNING,
        pid          = 0
    }
end

function json_service_provider:init(service_table, name)
    if service_table then self:set_service(service_table) end

    if name then self:set_name(name) end
end

---@param name string
function json_service_provider:set_name(name)
    self.name = name

    return self
end

function json_service_provider:set_service(service_table)
    self.service = safe_service(service_table)

    return self
end

function json_service_provider:stop()
    local service = self.service

    if service.status == service_status.EXITED then
        return
    end

    awesome.kill(-service.pid, awesome.unix_signal.SIGTERM)

    service.status = service_status.STOPPED
end

function json_service_provider:start()
    ---@type Promise<boolean>
    local promise

    self.service.status = service_status.STARTING

    if #self.service.dependencies == 0 then
        promise = Promise.resolve(true)
    else
        promise = check_dependencies(self.service.dependencies)
    end

    promise
        :after(function(met)
            if not met then
                self.service.status = service_status.ERROR

                error("Dependencies unmet")
            end

            -- https://awesomewm.org/doc/api/libraries/awful.spawn.html#easy_async_with_shell
            self.service.pid = awful.spawn.easy_async_with_shell(self.service.exec, function(stdout, stderr, _, code)
                if not self.service.kill then
                    if code == 0 then
                        self.service.status = service_status.EXITED
                    else
                        self.service.status = service_status.ERROR
                    end
                end
            end)

            self.service.status = service_status.STARTED

            if self.service.kill then
                self.service.status = service_status.RUNNING

                awesome.connect_signal("exit", function()
                    self:stop()
                end)
            end
        end)
        :catch(function(err)
            print(self.name .. " - " .. tostring(err))
        end)
end

function json_service_provider:get_info()
    return {
        name = self.name,
        status = self.service.status,
        description = self.service.description,
        dependencies = self.service.dependencies,
        pid = self.service.pid
    }
end

return json_service_provider
