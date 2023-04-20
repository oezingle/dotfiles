local wibox = require("wibox")

local button = require("src.widgets.helper.button")

---@param icon string
---@param callback function
---@param _ string? tooltip. not implemented
---@return Widget
local function icon_button(icon, callback, _)
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