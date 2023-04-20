-- A very pretty MacOS-style toggle switch

local wibox            = require("wibox")
local no_scroll        = require("src.widgets.helper.function.no_scroll")
local good_thing_green = require("src.util.color.good_thing_green")

local config           = require("config")
local shapes           = require("src.util.shapes")

local function switch_widget(callback, state)
    callback = callback or function()
    end

    local bar = wibox.widget {
        widget = wibox.widget.progressbar,

        forced_height = 5,
        forced_width = 35,

        max_value = 100,
        value = 50,

        shape = shapes.rounded_rect(100),
        bar_shape = shapes.rounded_rect(100),

        color = config.progressbar.fg,
        background_color = config.progressbar.bg,
    }

    local rotate = wibox.widget {
        bar,
        layout = wibox.container.rotate,
        direction = "north"
    }

    state = state or false

    local function update_value_and_bg()
        bar.background_color = state and good_thing_green or config.progressbar.bg

        rotate.direction = state and "south" or "north"
    end

    update_value_and_bg()

    rotate:connect_signal("button::press", no_scroll(function()
        state = not state

        update_value_and_bg()

        callback(state)
    end))

    return rotate
end

return switch_widget
