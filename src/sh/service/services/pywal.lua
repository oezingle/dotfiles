
local service_status       = require("src.sh.service.status")
local lua_service_provider = require("src.sh.service.provider.lua")

local wal = require("src.util.wal")

local service              = lua_service_provider():set_info({
    name = "pywal",
    description = "Pywal color scheme generation",
})

function service:start()
    self.status = service_status.STARTING

    wal.create_hook()

    self.status = service_status.RUNNING
end

return service