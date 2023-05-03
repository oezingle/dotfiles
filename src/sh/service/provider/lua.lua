local class              = require("lib.30log")
local check_dependencies = require("src.sh.check_dependencies")

local service_status     = require("src.sh.service.status")


local awful = require("awful")

---@class LuaServiceProvider : LuaServiceProvider.InitArgs, Service, LogBaseFunctions
---@field pidwatch fun(self: LuaServiceProvider, exec: string)
---@field check_dependencies fun(self: LuaServiceProvider): Promise<true>
---@operator call:LuaServiceProvider
local lua_service_provider = class("LuaServiceProvider", {
    service_status = service_status,

    status = service_status.NOT_RUNNING,
    pid = 0
})

---@class LuaServiceProvider.InitArgs
---@field name string
---@field description string
---@field dependencies string[]?
---@field kill boolean?

---@param args LuaServiceProvider.InitArgs
function lua_service_provider:init(args)
    if args then
        self:set_info(args)
    end
end

---@param args LuaServiceProvider.InitArgs
---@return self
function lua_service_provider:set_info(args)
    self.name = args.name
    self.description = args.description
    self.dependencies = args.dependencies or {}
    self.kill = args.kill or false

    return self
end

function lua_service_provider:pidwatch(exec)
    self.pid = awful.spawn.easy_async_with_shell(exec, function(stdout, stderr, _, code)
        if code == 0 then
            self.status = service_status.EXITED
        else
            self.status = service_status.ERROR
        end
    end)

    if self.kill then
        awesome.connect_signal("exit", function()
            self:stop()
        end)
    end
end

function lua_service_provider:check_dependencies()    
    return check_dependencies(self.dependencies)
        :after(function (met)
            if not met then
                self.status = service_status.ERROR

                error("Dependencies unmet")
            end

            return true
        end)
        :catch(function (err)
            print(err)
        end)
end

---@return Service.Info
function lua_service_provider:get_info()
    return {
        name = self.name,
        description = self.description,
        dependencies = self.dependencies,
        status = self.status,
        pid = self.pid
    }
end

function lua_service_provider:stop()
    if self.status == service_status.EXITED then
        return
    end

    awesome.kill(-self.pid, awesome.unix_signal.SIGTERM)

    self.state = service_status.STOPPED
end

return lua_service_provider
