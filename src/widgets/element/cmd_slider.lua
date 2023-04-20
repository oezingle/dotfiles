local wibox                 = require("wibox")
local gears                 = require("gears")
local gcolor                = gears.color
local gtimer                = gears.timer

local shapes                = require("src.util.shapes")
local bind_width_and_height = require("src.widgets.helper.function.bind_width_and_height")

local config                = require("config")

local no_scroll             = require("src.widgets.helper.function.no_scroll")

-- TODO volume/brightness sliders don't have initial values

-- I don't need no stinking handle!
---@param w table slider widget to create handle for
local function create_slider_bg(w)
    local value = w.value

    local maximum = w.maximum
    local minimum = w.minimum

    local percent_pos = (value - minimum) / (maximum - minimum)

    return gcolor {
        type  = "linear",

        from  = { 0, 1 },
        to    = { w.width, 1 },

        stops = {
            { 0,           config.button.hover },
            { percent_pos, config.button.hover },
            { percent_pos, config.button.normal },
            { 1,           config.button.normal },
        }
    }
end

---@param args { on_value_change: function?, image: string, id: string?, on_right_click: function?, update: fun(): Promise<number> }
local function cmd_slider(args)
    args = args or {}

    local on_value_change = args.on_value_change

    local on_right_click = args.on_right_click

    local update = args.update

    local slider = wibox.widget {
        bar_shape    = shapes.rounded_rect(),
        handle_width = 0,
        value        = 25,
        maximum      = 100,
        minimum      = 0,

        id           = args.id,

        bar_color    = config.button.normal,

        widget       = wibox.widget.slider
    }

    bind_width_and_height(slider)

    local is_pressing = false

    slider:connect_signal("button::press", function(w, _, _, button)
        if button == 1 then
            is_pressing = true
        elseif button == 3 then
            if on_right_click then
                on_right_click()
            end
        end
    end)
    slider:connect_signal("button::release", no_scroll(function()
        is_pressing = false
    end))

    local last_value = -1.0

    slider:connect_signal("property::value", function(w)
        -- TODO limit to 20 notches or so?
        local value = w.value

        if value ~= last_value then
            if is_pressing then
                if on_value_change then
                    on_value_change(value)                    
                end
            end

            w.bar_color = create_slider_bg(w)

            last_value = value
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
                image = args.image,
                resize = true,
                forced_width = 32,
                forced_height = 32,
                widget = wibox.widget.imagebox
            },
            layout = wibox.container.place,
        },

        layout = wibox.layout.stack
    }

    -- timer to update the visual
    local timer = gtimer {
        timeout = 0.2,
        autostart = true,
        callback = function()
            if not stack.visible then
                return
            end

            -- don't bother updating the slider if the user is pressing on it
            if is_pressing then
                return
            end

            update():after(function(value)
                if is_pressing then
                    return
                end

                slider.value = value
            end)
        end
    }

    stack.timer = timer

    return stack
end

return cmd_slider
