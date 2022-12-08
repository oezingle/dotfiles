local wibox = require("wibox")
local awful = require("awful")
local config = require("config")
local shapes = require("src.util.shapes")

local icon_button = require("src.widgets.components.icon_button")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local confirm_callback = function () end

local confirm_widget = awful.popup {
    widget = {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = 10,
            {
                widget = wibox.widget.textbox,
                font = "Inter Bold 14",
                text = "[Placeholder]",

                id = "confirm-text"
            },
            {
                layout = wibox.layout.flex.horizontal,
                icon_button(config_dir .. "icon/confirm/close-circle-outline.svg", nil, "No"),
                icon_button(config_dir .. "icon/confirm/checkmark-circle-outline.svg", function()
                    if confirm_callback then
                        confirm_callback()
                    end
                end, "Yes"),

                spacing = 10,
                forced_height = 64
            }
        },
        widget = wibox.container.margin,
        margins = 10,
    },

    placement = awful.placement.centered,
    ontop = true,
    visible = false,

    bg = config.popup.bg,
    fg = config.popup.fg,

    hide_on_right_click = true,

    shape = shapes.rounded_rect()
}

-- TODO keyboard controls: enter=yes, esc=no

local function confirm(callback, context)
    confirm_callback = callback

    context = context or "take this action"

    confirm_widget.widget:get_children_by_id("confirm-text")[1].text = "Are you sure you want to " .. context .. "?"    

    confirm_widget.visible = true
end

return confirm