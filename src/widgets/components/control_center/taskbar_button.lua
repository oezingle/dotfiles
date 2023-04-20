local wibox                 = require("wibox")
local awful                 = require("awful")

local config                = require("config")
local wal_svg               = require("src.widgets.element.wal_svg")
local autoclose             = require("src.widgets.helper.function.autoclose")
local create_control_center = require("src.widgets.components.control_center.popup")

local get_decoration_color  = require("src.util.color.get_decoration_color")
local get_icon              = require("src.util.fs.get_icon")
local no_scroll             = require("src.widgets.helper.function.no_scroll")
local shapes                = require("src.util.shapes")

local control_center        = create_control_center()

local function create_button()
    local button = wibox.widget {
        widget = wal_svg,
        image = get_icon("options-outline.svg"),
        replace = "white"
    }

    local popup = awful.popup {
        widget = control_center,

        shape = shapes.rounded_rect(),
        ontop = true,
        visible = false,

        bg = config.popup.bg,

        border_width = config.border.floating_width,
        border_color = config.popup.border or get_decoration_color()
    }

    autoclose(popup)

    popup:connect_signal("property::visible", function(p)
        if p.widget then
            p.widget.visible = p.visible

            p.widget:emit_signal("property::visible")
        end
    end)

    button:connect_signal("button::press", no_scroll(function()
        if popup.visible then
            popup.visible = false
        else
            popup:move_next_to(mouse.current_widget_geometry)
        end
    end))

    return button
end

return create_button
