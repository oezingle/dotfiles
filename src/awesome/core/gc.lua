
local timer_add  =require("src.util.timer.timer_add")
local configuration = require("src.configuration")

---@type Awesome.Gears.Timer | Zingle.GLibTimer | nil
local gc_timer = nil

local function enable_gc ()
    gc_timer = timer_add({
        callback = function ()
            log.debug("Running garbage collector")

            collectgarbage("collect")
        end,
        --- TODO FIXME this in config
        timeout = 30,
        autostart = true
    })
end 

---@diagnostic disable-next-line:undefined-global
if not _TEST then
    configuration:on_change(function (info)
        local config = info.configuration

        local gc = config.tasks.garbage_collection

        if gc_timer then
            if gc.enabled then
                gc_timer:start()
            else
                gc_timer:stop()
            end

            gc_timer.timeout = gc.timeout
        end
    end)
end

return enable_gc