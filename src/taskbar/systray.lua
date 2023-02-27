
local wibox = require("wibox")

local function create_systray()
    local systray = wibox.widget.systray()

    systray:set_horizontal(false)

    return systray
end

return create_systray