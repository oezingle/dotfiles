local wibox = require("wibox")

local function default_divider ()
    return wibox.widget {
        layout = wibox.container.margin,
        margins = 5
    }
end

return default_divider
