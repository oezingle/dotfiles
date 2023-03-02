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
local awful                  = require('awful')
local config                 = require("config")
local get_icon               = require("src.util.fs.get_icon")
local no_scroll              = require("src.widgets.helper.no_scroll")
local scratch                = require("src.util.scratch")
local dpi                    = require("beautiful").xresources.apply_dpi
local get_font               = require("src.util.get_font")
local translations           = require("src.util.translations")
local good_thing_green       = require("src.util.color.good_thing_green")

--- Turn an integer from UPower into a table
---@param time number
local function table_upower_time(time)
    local seconds = time % 60

    local minutes = math.floor((time % 3600) / 60)

    local hours = math.floor(time / 3600)

    return {
        seconds = seconds,
        minutes = minutes,
        hours   = hours
    }
end

--- Turn an integer from UPower into a string
---@param time number
local function format_upower_time(time)
    local table = table_upower_time(time)

    return tostring(table.hours) .. "h " .. tostring(table.minutes) .. "m"
end

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
                    max_value        = 100,
                    forced_width     = 14.7,
                    background_color = "#00000000",
                    color            = config.progressbar.fg,
                    value            = 0,
                    widget           = wibox.widget.progressbar,
                    id               = "battery-bar"
                }
            },
            {
                widget = wibox.widget.imagebox,
                image = get_icon("battery/battery-dead-outline.svg"),
                id = "battery-icon"
            },
        }
    }

    local battery_tooltip = awful.tooltip {
        objects = { battery_widget },
        mode = 'outside',
        delay_show = 0,
        preferred_positions = { 'right', 'left', 'top', 'bottom' },
        preferred_alignments = { 'middle', 'front', 'back' },
        margin_leftright = dpi(8),
        margin_topbottom = dpi(8),
        bg = config.popup.bg,
        fg = config.popup.fg,
        font = get_font(10),
    }

    local cb = function(widget, device)
        local battery_bar = widget:get_children_by_id("battery-bar")[1]
        local battery_icon = widget:get_children_by_id("battery-icon")[1]

        -- only change the value every 10%, so that redraws aren't too often
        battery_bar.value = math.floor(device.percentage / 10) * 10

        local is_charging = device.state == UPowerGlib.DeviceState.CHARGING

        local fully_charged = device.state == UPowerGlib.DeviceState.FULLY_CHARGED

        if is_charging or fully_charged then
            battery_bar.color = good_thing_green
        else
            battery_bar.color = config.progressbar.fg
        end

        if is_charging then
            battery_icon.image = get_icon("battery/battery-charging-outline.svg")
        else
            battery_icon.image = get_icon("battery/battery-dead-outline.svg")
        end

        local state_string = ({
                    [UPowerGlib.DeviceState.UNKNOWN]       = translations.battery.state.unknown,
                    [UPowerGlib.DeviceState.CHARGING]      = translations.battery.state.charging,
                    [UPowerGlib.DeviceState.DISCHARGING]   = translations.battery.state.discharging,
                    [UPowerGlib.DeviceState.EMPTY]         = translations.battery.state.empty,
                    [UPowerGlib.DeviceState.FULLY_CHARGED] = translations.battery.state.fully_charged,
                    [UPowerGlib.DeviceState.PENDING_CHARGE] = translations.battery.state.pending_charge,
                    [UPowerGlib.DeviceState.PENDING_DISCHARGE] = translations.battery.state.pending_discharge,
                    [UPowerGlib.DeviceState.LAST]          = translations.battery.state.last
            })[device.state]

        local warning_string = ({
                    [UPowerGlib.DeviceLevel.ACTION] = translations.battery.warning.action,
                    [UPowerGlib.DeviceLevel.CRITICAL] = translations.battery.warning.critical
            })[device.warning_level]

        battery_tooltip.textbox.text = state_string ..
            " - " .. tostring(math.floor(device.percentage)) .. "%" .. "\n" ..
            ((is_charging or fully_charged) and
            (format_upower_time(device.time_to_full) .. " " .. translations.battery.to_full) or
            (format_upower_time(device.time_to_empty) .. " " .. translations.battery.to_empty)
            ) ..
            (device.capacity > 0 and ("\n" .. tostring(math.floor(device.capacity)) ..
            "% " .. translations.battery.health) or "") ..
            (warning_string and string.format("\n\n" .. translations.battery.warning.message, warning_string) or "")

        --[[
            if i remove powertop:
                 - device.vendor
                 - device.technology
                 - device.temperature
                 - device.model
                 - device.has_statistics and statistics
                 - device.has_history and history
                 - device.energy_rate
                 - device.capacity

            the UPower site wants me to use device.battery_level instead of percentages but nahh
        ]]
    end

    cb(battery_widget, battery_widget.device)

    battery_widget:connect_signal('upower::update', cb)

    battery_widget:connect_signal("button::press", no_scroll(function()
        scratch.terminal("pkexec powertop", true)
    end))

    return battery_widget
end

return create_battery_widget
