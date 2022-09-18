local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local shapes                = require("util.shapes")
local bind_width_and_height = require("widgets.helper.bind_width_and_height")
local create_slider_bg      = require("widgets.helper.create_slider_bg")

local update_widget = require("widgets.helper.update")
local config = require("config")

local no_scroll = require("widgets.helper.no_scroll")

local config_dir = gears.filesystem.get_configuration_dir()

local function do_nothing(...) end

local function cmd_slider(args)
    args = args or {}

    local throttle = args.throttle or false

    local on_value_change = args.on_value_change or do_nothing

    local update_command = args.update_command

    local slider = wibox.widget {
        bar_shape    = shapes.rounded_rect(),
        handle_width = 0,
        value        = 25,
        maximum      = 100,
        minimum      = 0,

        id = args.id,

        bar_color = config.button.normal,

        widget = wibox.widget.slider
    }

    bind_width_and_height(slider)

    local is_pressing = false

    local last_value = 0.0

    -- timer that gets constantly cancelled and re-inited so that
    -- command calls are throttled
    local submit_change = gears.timer {
        timeout = 0.5,
        single_shot = true,
        callback = function()
            if throttle then
                on_value_change(slider.value)
            end

            is_pressing = false
        end
    }

    slider:connect_signal("property::value", function(w)
        if is_pressing then
            if w.value ~= last_value and not throttle then
                on_value_change(slider.value)
            end

            submit_change:stop()
            submit_change:again()
        end

        if w.value ~= last_value then
            w.bar_color = create_slider_bg(w)

            last_value = w.value
        end
    end)

    local rotate = wibox.container {
        slider,
        widget = wibox.container.rotate,
        direction = "east",
    }

    local stack = wibox.widget {
        rotate,
        {
            {
                image = args.image or config_dir .. "icon/sunny-outline.svg",
                resize = true,
                forced_width = 32,
                forced_height = 32,
                widget = wibox.widget.imagebox
            },
            layout = wibox.container.place,
        },

        layout = wibox.layout.stack
    }

    slider:connect_signal("button::press", no_scroll(function()
        is_pressing = true
    end))

    -- create a timer to recreate the background
    -- TODO doesn't do anything
    --[[
    gears.timer {
        timeout = 1,
        single_shot = true,
        autostart = true,
        function ()
            -- getting drawn means width and height are bound
            slider:emit_signal("widget::redraw_needed")

            -- set bar color properly this time
            slider.bar_color = create_slider_bg(slider)
        end
    }
    ]]

    return update_widget {
        widget = stack,
        update_callback = function()
            -- Let the user take the wheel
            if is_pressing then
                return
            end

            awful.spawn.easy_async_with_shell(update_command, function(result)
                -- Check again in case there was a state change during execution time
                if is_pressing then
                    return
                end

                local asnumber = tonumber(result)

                if type(asnumber) ~= "nil" then
                    slider.value = asnumber
                end
            end)
        end,
        timeout = 0.5
    }
end

return cmd_slider
