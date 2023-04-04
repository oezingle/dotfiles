local wibox = require("wibox")

local function default_button()
    return wibox.widget {
        layout = wibox.container.background,
        {
            layout = wibox.container.margin,
            margins = 2,
            {
                layout = wibox.layout.align.horizontal,
                expand = "inside",
                {
                    widget = wibox.widget.textbox,
                    id = "text-role"
                },
                nil,
                {
                    widget = wibox.widget.textbox,
                    id = "icon-role"
                }
            }
        }
    }
end

return default_button
