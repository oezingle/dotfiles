local wibox = require("wibox")

local no_scroll = require("src.widgets.helper.no_scroll")

local config = require("config")
local shapes = require("src.util.shapes")

local button = {}

--- Place a widget in a background with hover effects, and call a callback when clicked.
--- No styling.
---@param widget Widget
---@param callback function
---@return Widget
function button.button(widget, callback)
    local button = wibox.widget {
        widget,

        bg = config.button.normal,

        layout = wibox.container.background,

        shape = shapes.rounded_rect()
    }

    button:connect_signal("mouse::enter", function()
        widget.old_bg = widget.bg

        widget.bg = config.button.hover
    end)

    button:connect_signal("mouse::leave", function()
        if widget.old_bg then
            widget.bg = widget.old_bg

            widget.old_bg = nil
        end
    end)

    button:connect_signal("button::press", no_scroll(callback))

    return button
end

---@param widget Widget
---@param callback function
function button.centered (widget, callback)
    return button.button({
        widget,

        layout = wibox.container.place
    }, callback)
end

return setmetatable(button, {
    __call = function(_, ...)
        button.button(...)
    end
})
