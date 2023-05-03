local config               = require("config")

local service_status       = require("src.sh.service.status")
local lua_service_provider = require("src.sh.service.provider.lua")

local service              = lua_service_provider():set_info({
    name = "gestures",
    description = "Gesture support",
    dependencies = { "libinput-gestures" },
    kill = true
})

function service:start()
    if config.gimmicks.gestures then
        self.status = service_status.STARTING

        self:check_dependencies()
            :after(function()
                self:pidwatch("libinput-gestures")

                self.status = service_status.RUNNING
            end)
    end
end

return service
