local wibox                = require("wibox")
local awful                = require("awful")
local config               = require("config")
local no_scroll            = require("src.widgets.helper.function.no_scroll")
local check_dependencies   = require("src.sh.check_dependencies")
local spawn                = require("src.agnostic.spawn")
local open_manager         = require("src.util.xfsettings.open_manager")

local shapes               = require("src.util.shapes")
local redshift             = require("src.util.redshift")

local create_music_widget  = require("src.widgets.components.music")
local cmd_slider           = require("src.widgets.element.cmd_slider")
local icon_button          = require("src.widgets.components.control_center.icon_button")

local get_icon             = require("src.util.fs.get_icon")

local Promise              = require("src.util.Promise")

---@param icon string
---@param callback function
---@param _ string tooltip - not yet implemented
---@param initial boolean
local function toggle_icon_button(icon, callback, _, initial)
    local state = initial or false

    local button = icon_button(icon, function () end)

    local function update_color()
        if state then
            button.bg = config.button.active

            button.old_bg = nil
        else
            button.bg = config.button.normal

            button.old_bg = nil
        end
    end

    button:connect_signal("button::press", no_scroll(function()
        state = not state

        update_color()

        callback(state)
    end))

    update_color()

    return button
end

local function create_control_center()
    local widget = wibox.widget {
        {
            {
                nil,
                bg = config.button.normal,
                widget = wibox.container.background,
                shape = shapes.rounded_rect(),
                id = "music-container",
                visible = false
            },
            {
                layout = wibox.layout.grid,
                forced_num_rows = 4,
                forced_num_cols = 3,
                forced_height = 320,
                forced_width = 290,
                spacing = 10,
                id = "layout-grid",
                expand = true,
                homogeneous = true
            },
            layout = wibox.layout.fixed.horizontal,
            spacing = 10,
        },
        widget = wibox.container.margin,
        margins = 10
    }

    local grid = widget:get_children_by_id("layout-grid")[1]

    local brightness_control = cmd_slider {
        image = get_icon("sunny-outline.svg"),
        on_value_change = function(slider_value)
            awful.spawn("xbacklight -set " .. slider_value)
        end,
        update = function()
            return Promise(function(res)
                spawn("xbacklight -get", function(result)
                    local value = tonumber(result)

                    res(value)
                end)
            end)
        end,
        on_right_click = function()
            -- TODO fallback to arandr
            open_manager("display")
        end
    }

    -- brightness slider
    grid:add_widget_at(
        brightness_control,
        1, 1, 3, 1
    )

    local volume_control = cmd_slider {
        image = get_icon("volume/volume-high-outline.svg"),
        on_value_change = function(slider_value)
            spawn("pactl -- set-sink-volume $(pactl get-default-sink) " .. slider_value .. "%")
        end,
        id = "cmd-slider-volume",
        update = function()
            return Promise(function(res)
                spawn("pactl get-sink-volume $(pactl get-default-sink)", function(result)
                    local percentage = result:match("(%d+)%%")

                    local value = tonumber(percentage)

                    res(value)
                end)
            end)
        end,
        on_right_click = function()
            spawn("pavucontrol")
        end
    }

    -- volume slider
    grid:add_widget_at(
        volume_control,
        1, 2, 3, 1
    )

    -- network manager
    grid:add_widget_at(
        icon_button(get_icon("control-center/wifi-outline.svg"), function()
            -- TODO integrate into a thin applet - select network, create config

            awful.spawn("nm-connection-editor")
        end, "Network Configuration"),
        1, 3, 1, 1
    )

    -- bluetooth
    grid:add_widget_at(
        icon_button(get_icon("control-center/bluetooth-outline.svg"), function()
            -- TODO bluetooth applet
        end, "Bluetooth Configuration"),
        2, 3, 1, 1
    )

    grid:add_widget_at(
        toggle_icon_button(get_icon("control-center/moon.svg"), function()
            redshift.toggle()
        end, "Toggle Night Colors", redshift.get_state() == 1),
        3, 3, 1, 1
    )

    -- do not disturb
    -- might need to be a toggle_icon_button
    grid:add_widget_at(
        icon_button(get_icon("control-center/notifications-outline.svg"), function()
            NotificationCenter.toggle()
        end),
        4, 1, 1, 1
    )

    -- system specs
    grid:add_widget_at(
        icon_button(get_icon("control-center/hardware-chip-outline.svg"), function()
            SystemInfo.toggle()
        end),
        4, 2, 1, 1
    )

    -- power menu
    grid:add_widget_at(
        icon_button(get_icon("exit-outline.svg"), function()
            awesome.emit_signal('module::exit_screen:show')
        end),
        4, 3, 1, 1
    )

    brightness_control.visible = false
    volume_control.visible = false

    local music_widget

    -- show music widget if playerctl is installed
    check_dependencies({ "playerctl" })
        :after(function(met)
            if not met then
                return
            end

            local music_container = widget:get_children_by_id("music-container")[1]

            music_widget = create_music_widget()

            music_container.widget = music_widget
            music_container.visible = true
        end)

    widget:connect_signal("property::visible", function(w)
        local visible = w.visible

        if music_widget then
            music_widget.visible = visible
            music_widget:emit_signal("property::visible")
        end

        if visible then
            brightness_control.timer:again()
            volume_control.timer:again()
        else
            brightness_control.timer:stop()
            volume_control.timer:stop()
        end

        brightness_control.visible = visible
        volume_control.visible = visible
    end)

    return widget
end

return create_control_center