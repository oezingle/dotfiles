local TimerService = require("src.util.Service.TimerService")

local GarbageCollector = TimerService.create({
    name = "gc"
})

function GarbageCollector:on_timer()
    self.log.debug("Collecting Garbage")

    collectgarbage("collect")
end 

function GarbageCollector:on_config_change (config)
    local section = config.tasks.garbage_collection

    local timeout = section.timeout

    self.log.info("Config changed. Timeout =", timeout)

    self:set_timeout(timeout)
end

GarbageCollector:register()

return GarbageCollector