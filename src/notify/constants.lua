---@type { cycle_time_in_seconds: number, size: { width: number, close_button: number } }
local notif_constants = {
    -- Adjust for a smoother animation. Takes more resources, of course.
    cycle_time_in_seconds = 1,

    size = {
        width = 512,
        close_button = 24,
    }
}

return notif_constants
