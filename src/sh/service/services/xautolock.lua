local config               = require("config")

local service_status       = require("src.sh.service.status")
local lua_service_provider = require("src.sh.service.provider.lua")

local service              = lua_service_provider():set_info({
    name = "xautolock",
    description = "Screen locking on sleep",
    dependencies = { "xautolock" },
    kill = true
})

function service:start()
    if config.lock_time then
        self.status = service_status.STARTING

        self:check_dependencies()
            :after(function()
                self:pidwatch(string.format(
                    "xautolock -secure -detectsleep -time %s -locker \"dm-tool lock; systemctl suspend\"",
                    tostring(config.lock_time)))

                self.status = service_status.RUNNING
            end)
    end
end

return service
