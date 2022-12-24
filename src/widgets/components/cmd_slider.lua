local wibox = require("wibox")
local gears = require("gears")
local gcolor = gears.color
local gtimer = gears.timer

local shapes                = require("src.util.shapes")
local bind_width_and_height = require("src.widgets.helper.bind_width_and_height")
local spawn                 = require("src.agnostic.spawn")

local update_widget = require("src.widgets.helper.update")
local config = require("config")

local no_scroll = require("src.widgets.helper.no_scroll")

local config_dir = gears.filesystem.get_configuration_dir()

local function do_nothing(...) end

-- I don't need no stinking handle!
---@param w table slider widget to create handle for
local function create_slider_bg(w)
    local value = w.value

    local maximum = w.maximum
    local minimum = w.minimum

    local percent_pos = (value - minimum) / (maximum - minimum)

    return gcolor {
        type = "linear",

        from = { 0, 1 },
        to   = { w.width, 1 },

        stops = {
            { 0, config.button.hover },
            { percent_pos, config.button.hover },
            { percent_pos, config.button.normal },
            { 1, config.button.normal },
        }
    }
end

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
    local submit_change = gtimer {
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

    --[[
        return update_widget {
        widget = stack,
        update_callback = function()
            -- Let the user take the wheel
            if is_pressing then
                return
            end

            spawn(update_command, function(result)
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
    ]]

    -- timer to update the visual
    gtimer {
        timeout = 0.5,
        call_now = true,
        autostart = true,
        callback = function()
            if not stack.visible then
                return
            end

            -- Let the user take the wheel
            if is_pressing then
                return
            end

            spawn(update_command, function(result)
                -- Check again in case there was a state change during execution time
                if is_pressing then
                    return
                end

                local asnumber = tonumber(result)

                if type(asnumber) ~= "nil" then
                    slider.value = asnumber
                end
            end)
        end
    }

    return stack
end

return cmd_slider
