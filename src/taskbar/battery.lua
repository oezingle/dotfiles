local awesome_battery_widget = require("lib.awesome-battery_widget")
local wibox                  = require("wibox")
local config                 = require("config")
local config_dir             = require("gears.filesystem").get_configuration_dir()

local UPowerGlib = require("lgi").require('UPowerGlib')

local print = require("src.agnostic.print")

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
                image = config_dir .. "icon/battery/battery-dead-outline.svg"
            },
        }
    }

    local cb = function(widget, device)
        local battery_bar = widget:get_children_by_id("battery-bar")[1]
        
        battery_bar.value = device.percentage

        local is_charging = 
            device.state == UPowerGlib.DeviceState.CHARGING or
            device.state == UPowerGlib.DeviceState.FULLY_CHARGED

        if is_charging then
            battery_bar.color = "#6CC551"
        else
            battery_bar.color = config.progressbar.fg
        end
    end

    cb(battery_widget, battery_widget.device)

    battery_widget:connect_signal('upower::update', cb)

    return battery_widget
end

return create_battery_widget
