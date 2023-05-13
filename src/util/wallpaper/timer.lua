
local gtimer = require("gears.timer")

---@param config Wallpaper.Config
---@param set_current function
local function start_wallpaper_timer (config, set_current)
    if not config.is_list or #config.table > 1 then
        if config.time and config.time > 1 then
            gtimer {
                timeout = config.time,

                autostart = true,

                callback = function()
                    set_current()
                end
            }
        end
    end
end

return start_wallpaper_timer