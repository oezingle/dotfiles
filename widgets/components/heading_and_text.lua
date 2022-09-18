
local wibox = require("wibox")

local function heading_and_text (heading, text)
    return wibox.widget {
        {
            widget = wibox.widget.textbox,
            text = heading,
            font = "Inter Bold 10"
        },
        {
            widget = wibox.widget.textbox,
            text = text
        },
        layout = wibox.layout.fixed.vertical
    }
end

return heading_and_text