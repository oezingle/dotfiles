local TimerService = require("src.util.Service.TimerService")
local load_scripts = require("src.awesome.core.load_scripts")

local LoadScripts = TimerService.create({
    name = "load-scripts"
})

-- TODO move logic here?? probably not?
function LoadScripts:on_timer()
    load_scripts.poll()
end

function LoadScripts:on_config_change(config)
    local section = config.tasks.load_scripts

    local timeout = section.timeout

    self.log.info("Config changed. Timeout =", timeout)

    self:set_timeout(timeout)
end

LoadScripts:register()

return LoadScripts