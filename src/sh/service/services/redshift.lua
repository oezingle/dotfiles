local service_status       = require("src.sh.service.status")
local lua_service_provider = require("src.sh.service.provider.lua")


local service = lua_service_provider():set_info({
    name = "redshift",
    description = "Redshift blue light adjustment",
    dependencies = { "redshift", "/usr/lib/geoclue-2.0/demos/agent" }
})

function service:start()
    self.status = service_status.STARTING

    self:check_dependencies()
        :after(function()
            local redshift = require("src.util.redshift")

            redshift.init()

            -- TODO sort out geoclue man - why does the demo have to run?
            self:pidwatch("/usr/lib/geoclue-2.0/demos/agent")

            self.status = service_status.RUNNING
        end)
end

return service
