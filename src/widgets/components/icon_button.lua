local wibox = require("wibox")

local button_widget = require("src.widgets.util.button")

local function icon_button(icon, callback, tooltip)
    local widget = button_widget(
        {
            widget = wibox.widget.imagebox,
            resize = true,
            forced_width = 32,
            forced_height = 32,
            image = icon,
        },
        callback,
        tooltip
    )

    return widget
end

return icon_button