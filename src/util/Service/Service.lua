local Promise            = require("src.polyfill.Promise")
local map                = require("src.polyfill.list.map")
local includes           = require("src.polyfill.list.includes")
local Set                = require("src.util.Set")
local PersistentStorage  = require("src.util.PersistentStorage")
local dir                = require("src.util.dir")
local ConfigurationMixin = require("src.configuration.ConfigurationMixin")

-- TODO FIXME default services should be enabled on first boot if config doesn't exist.

---@class Zingle.Awesome.Service : Log.BaseFunctions, Zingle.Awesome.ConfigurationMixin
---@field log Logger
---@field start fun(self: self | string): Promise?
---@field stop fun(self: self | string): Promise?
---@field restart fun(self: self | string): Promise?
---@field status Zingle.Awesome.Service.Status
---@field dependents Zingle.Set<string>
---
---@field start_jobs table<string, Promise<Zingle.Awesome.Service>>
---@field stop_jobs table<string, Promise<Zingle.Awesome.Service>>
---@field names table<string, Zingle.Awesome.Service>
---@field unregistered table<string, Zingle.Awesome.Service>
---@field enabled Zingle.Set<string>
---
---@field private start_by_name fun(name: string)
---@field private stop_by_name fun(name: string)
---@field private start_by_instance fun(instance: Zingle.Awesome.Service): Promise<Zingle.Awesome.Service>
---@field private stop_by_instance fun(instance: Zingle.Awesome.Service): Promise<Zingle.Awesome.Service>
---@operator call:Zingle.Awesome.Service
local Service            = class("Zingle.Awesome.Service", {
    names        = {},
    unregistered = {},

    start_jobs   = {},
    stop_jobs    = {},

    enabled      = Set(PersistentStorage.create(dir.config("services.json", true)))
})

-- No faffing about
Service.log              = log

Service:with(ConfigurationMixin)

-- Create weak tables
setmetatable(Service.names, { __mode = "v" })
setmetatable(Service.unregistered, { __mode = "v" })

---@class Zingle.Awesome.Service.Options
---@field name string
--- TODO FIXME move exec to BashService
---@field exec string? -- TODO just execute in bash
---@field dependencies string[]?

---@enum Zingle.Awesome.Service.Status
Service.statuses = {
    STOPPED  = "Stopped",
    STOPPING = "Stopping",
    STARTING = "Starting",
    RUNNING  = "Running",
    ERROR    = "Error"
}

---@param options Zingle.Awesome.Service.Options
function Service:init(options)
    self:use_config()

    self.name = options.name
    Service.unregistered[self.name] = self

    self.exec = options.exec

    self.status = Service.statuses.STOPPED

    self.dependencies = options.dependencies or {}
    self.dependents = Set()
end

-- Instances (individual services) may not provide this callback, so we provide a default
do
    -- store field as var so language server can't complain about duplicate fields
    local field = "on_config_change"
    Service[field] = function() end
end

function Service:set_logger(log)
    self.log = log

    return self
end

---@param name string
function Service.by_name(name)
    local service = Service.names[name]

    if not service then
        Service.log.error(string.format("Unknown service requested by name %q", name))

        return
    end

    return service
end

---@param name string
function Service.start_by_name(name)
    local service = Service.by_name(name)

    if not service then
        return
    end

    return Service.start(service)
end

---@param name string
function Service.stop_by_name(name)
    local service = Service.by_name(name)

    if not service then
        return
    end

    return Service.stop(service)
end

---@param self Zingle.Awesome.Service
function Service.start_by_instance(self)
    self.log.info(string.format("Starting service %s", self.name))

    Service.stop_jobs[self.name] = nil

    if not Service.start_jobs[self.name] then
        self.status = Service.statuses.STARTING

        Service.start_jobs[self.name] = Promise.all(map(
                self.dependencies,
                function(dependency)
                    return Service.start(dependency)
                        ---@param service Zingle.Awesome.Service
                        :after(function(service)
                            service.dependents:add(self.name)
                        end)
                end
            ))
            :after(function()
                if self.start ~= Service.start then
                    return self.start(self)
                else
                    -- TODO spawn
                end
            end)
            :after(function()
                --- TODO doesn't seem to take effect
                self.status = Service.statuses.RUNNING

                return self
            end)
    end

    return Service.start_jobs[self.name]
end

---@param self Zingle.Awesome.Service
function Service.stop_by_instance(self)
    self.log.info(string.format("Stopping service %s", self.name))

    Service.start_jobs[self.name] = nil

    if not Service.stop_jobs[self.name] then
        self.status = Service.statuses.STOPPING

        Service.stop_jobs[self.name] = Promise.all(map(
                self.dependents:keys(),
                function(dependent)
                    -- TODO FIXME this fucks up restart.
                    self.log.warn(string.format("Stopping dependent service %q", dependent))

                    return Service.stop(dependent)
                end
            ))
            :after(function()
                return self.stop(self)
            end)
            :after(function()
                self.status = Service.statuses.STOPPED

                for _, dependency in pairs(self.dependencies) do
                    Service.names[dependency].dependents:remove(self.name)
                end

                return self
            end)
    end

    return Service.stop_jobs[self.name]
end

--- Allow :start with tables (instances) or strings (service name)
---@param self string | Zingle.Awesome.Service
function Service.start(self)
    if type(self) == "string" then
        return Service.start_by_name(self)
    else
        return Service.start_by_instance(self)
    end
end

--- Allow :stop with tables (instances) or strings (service name)
---@param self string | Zingle.Awesome.Service
function Service.stop(self)
    if type(self) == "string" then
        return Service.stop_by_name(self)
    else
        return Service.stop_by_instance(self)
    end
end

function Service.restart(self)
    return Service.stop(self)
        :after(function()
            return Service.start(self)
        end)
end

---@param options Zingle.Awesome.Service.Options
---@return Zingle.Awesome.Service
function Service.create(options)
    local instance = Service(options)

    return instance
end

function Service.register(self)
    local custom_exec = not self.exec

    -- if it has an exec string, these must not be overriden
    -- if it does not, these must be overriden
    assert(custom_exec ~= (self.start == Service.start), string.format(
        "Service %q %s start callback", self.name, custom_exec and "overrides" or "does not override"
    ))
    assert(custom_exec ~= (self.stop == Service.stop), string.format(
        "Service %q %s stop callback", self.name, custom_exec and "overrides" or "does not override"
    ))

    Service.unregistered[self.name] = nil
    Service.names[self.name] = self
end

function Service.warn_unregistered()
    for name in pairs(Service.unregistered) do
        Service.log.error(string.format(
            "Service %s is not registered. Use Service.register(service)", name
        ))
    end
end

function Service.start_all()
    Service.warn_unregistered()

    local jobs = {}
    for name in pairs(Service.enabled) do
        local job = Service.start(name)

        table.insert(jobs, job)
    end

    return Promise.all(jobs)
end

---@param except string[]?
function Service.stop_all(except)
    except = except or {}

    local jobs = {}
    for name, service in pairs(Service.names) do
        if service.status == Service.statuses.RUNNING or service.status == Service.statuses.STARTING and not includes(except, name) then
            local job = Service.stop(service)

            table.insert(jobs, job)
        end
    end

    return Promise.all(jobs)
end

function Service.enable(name)
    local service = Service.by_name(name)

    if not service then
        return false
    end

    Service.enabled:add(name)

    return true
end

function Service.disable(name)
    local service = Service.by_name(name)

    if not service then
        return false
    end

    Service.enabled:remove(name)

    return true
end

return Service
