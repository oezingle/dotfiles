
local timer_add  =require("src.util.timer.timer_add")
local configuration = require("src.configuration")

local load_scripts = require("src.awesome.core.load_scripts")

---@type Awesome.Gears.Timer | Zingle.GLibTimer | nil
local poll_timer = nil

local function enable_poll_scripts ()
    load_scripts.poll()
    poll_timer = timer_add({
        callback = load_scripts.poll,
        timeout = 30,
        autostart = true
    })
end

---@diagnostic disable-next-line:undefined-global
if not _TEST then
    configuration:on_change(function (info)
        local config = info.configuration

        local load_scripts_config = config.tasks.load_scripts

        if poll_timer then
            if load_scripts_config.enabled then
                poll_timer:start()
            else
                poll_timer:stop()
            end

            poll_timer.timeout = load_scripts_config.timeout
        end
    end)
end

return enable_poll_scripts