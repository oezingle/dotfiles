---@type { cycle_time_in_seconds: number, size: { width: number, close_button: number } }
local notif_constants = {
    -- Adjust for a smoother animation. Takes more resources, of course.
    -- TODO put this in config.lua you bellend
    cycle_time_in_seconds = 2,

    size = {
        width = 512,
        close_button = 24,
    }
}

return notif_constants
