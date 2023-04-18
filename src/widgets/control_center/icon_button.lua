local wibox = require("wibox")

local button = require("src.widgets.util.button")

local function icon_button(icon, callback)
    return button.centered(
        {
            widget = wibox.widget.imagebox,
            resize = true,
            forced_width = 32,
            forced_height = 32,
            image = icon,
        },
        callback
    )
end

return icon_button