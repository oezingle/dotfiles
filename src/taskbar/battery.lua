-- https://lazka.github.io/pgi-docs/UPowerGlib-1.0/classes/Device.html

local lgi = require("lgi")

local has_upower = pcall(lgi.require, "UPowerGlib")

if not has_upower then
    local print = require("src.agnostic.print")

    print("disabling battery widget: Requires upower")

    return false
end

local UPowerGlib             = lgi.require("UPowerGlib")
local awesome_battery_widget = require("lib.awesome-battery_widget")
local wibox                  = require("wibox")
local config                 = require("config")
local config_dir             = require("gears.filesystem").get_configuration_dir()

local function create_battery_widget(s)
    local battery_widget = awesome_battery_widget {
        screen = s,
        use_display_device = true,
        --widget_template = wibox.widget.imagebox
        widget_template = {
            layout = wibox.layout.stack,
            {
                layout = wibox.container.margin,
                left = 3,
                top = 8,
                bottom = 8,
                right = 7,
                {
                    max_value = 1,
                    forced_width = 14.7,

                    background_color = "#00000000",

                    color = config.progressbar.fg,

                    value  = 0,
                    widget = wibox.widget.progressbar,

                    id = "battery-bar"
                }
            },
            {
                widget = wibox.widget.imagebox,
                image = config_dir .. "icon/battery/battery-dead-outline.svg",
                id = "battery-icon"
            },
        }
    }

    local cb = function(widget, device)
        local battery_bar = widget:get_children_by_id("battery-bar")[1]
        local battery_icon = widget:get_children_by_id("battery-icon")[1]

        battery_bar.value = device.percentage

        local is_charging = device.state == UPowerGlib.DeviceState.CHARGING

        local fully_charged = device.state == UPowerGlib.DeviceState.FULLY_CHARGED

        if is_charging or fully_charged then
            battery_bar.color = "#6CC551"
        else
            battery_bar.color = config.progressbar.fg
        end

        if is_charging then
            battery_icon.image = config_dir .. "icon/battery/battery-charging-outline.svg"
        else
            battery_icon.image = config_dir .. "icon/battery/battery-dead-outline.svg"
        end
    end

    cb(battery_widget, battery_widget.device)

    battery_widget:connect_signal('upower::update', cb)

    return battery_widget
end

return create_battery_widget
