local wibox = require("wibox")

local no_scroll = require("src.widgets.helper.no_scroll")

local color_bg_widget = require('src.widgets.util.color_bg')

local config = require('config')

--- Wrap a widget with a clickable background
---@param widget table the child widget
---@param callback function? the callback function
---@param tooltip string? a tooltip 
---@param center boolean? whether or not to center the child widget (default true)
---@return table
local function button_widget(widget, callback, tooltip, center)
    if type(center) == "nil" then
        center = true
    end

    local child = center and wibox.widget { widget, layout = wibox.container.place } or widget

    local widget = color_bg_widget {
        child,
        bg = config.button.normal,
        fill_space = true
    }

    if callback then
        widget:connect_signal("button::press", no_scroll(callback))
    end

    widget:connect_signal("mouse::enter", function()
        widget.old_bg = widget.bg

        widget.bg = config.button.hover
    end)

    widget:connect_signal("mouse::leave", function()
        if widget.old_bg then
            widget.bg = widget.old_bg

            widget.old_bg = nil
        end
    end)

    -- TODO a nice tooltip
    --[[
    if tooltip then
        local tooltip_w = awful.tooltip {
            objects        = { widget },
            text = tooltip,
            mode = "outside"
        }        
    end
    ]]

    return widget
end

return button_widget
