
---@enum Service.Status
local service_status = {
    -- the service is running right now (service.kill == true)
    RUNNING     = 00,
    -- the service one-shot program has been called (service.kill == false)
    STARTED     = 10,
    -- the service is checking dependencies
    STARTING    = 20,
    -- probably will go unused
    -- STOPPING    = 30,

    -- the service was once running
    STOPPED     = 40,
    -- the service has never been started
    NOT_RUNNING = 50,
    -- the service has encountered an error (eg, dependency unmet)
    ERROR       = 60,
    -- the service is done everything it needs to do
    EXITED      = 70
}

return service_status