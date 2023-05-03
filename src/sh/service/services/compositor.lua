local config               = require("config")

local service_status       = require("src.sh.service.status")
local lua_service_provider = require("src.sh.service.provider.lua")

-- This isn't a JSON file because people need to tweak their picom flags based on their system

local service = lua_service_provider():set_info({
    name = "compositor",
    description = "X11 Compositor for Visual effects",
    dependencies = {},
    kill = true
})

function service:start()
    local compositor = config.apps.compositor
    
    -- picom
    if compositor and #compositor then
        self.status = service_status.STARTING

        self:pidwatch(compositor)

        self.status = service_status.RUNNING
    end
end

return service
