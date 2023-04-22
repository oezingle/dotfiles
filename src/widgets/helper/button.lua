local wibox = require("wibox")

local no_scroll = require("src.widgets.helper.function.no_scroll")

local config = require("config")
local shapes = require("src.util.shapes")

local button = {}


---@param w Widget
local function _set_widget_hovered(w)
    w.old_bg = w.bg

    w.bg = config.button.hover
end

---@param w Widget
local function _set_widget_unhovered(w)
    if w.old_bg then
        w.bg = w.old_bg

        w.old_bg = nil
    end
end

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

    button:connect_signal("mouse::enter", _set_widget_hovered)

    button:connect_signal("mouse::leave", _set_widget_unhovered)

    button:connect_signal("button::press", no_scroll(callback))

    return button
end

---@param widget Widget
---@param callback function
function button.centered(widget, callback)
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
