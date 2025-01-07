local wibox = require("wibox")
local awful = require("awful")
local Timer = require("src.util.Timer")

local loader = {}

-- TODO kinda boring.

local LOADER_BAR_COLOR = "#ffffff"
local LOADER_BG_COLOR = "#222222"

loader.widget = {}
loader.widget.primary = wibox.widget {
    widget = wibox.container.place,
    {
        widget = wibox.layout.fixed.vertical,
        spacing = 15,
        {
            widget = wibox.container.place,
            {
                id = "loader-arc",

                widget = wibox.container.arcchart,
                min_value = 0,
                max_value = 100,

                values = {
                    0,
                    0,
                    0,
                },

                colors = {
                    LOADER_BAR_COLOR,
                    LOADER_BG_COLOR,
                    LOADER_BAR_COLOR,
                },

                forced_width = 50,
                forced_height = 50,
                thickness = 5,
                rounded_edges = true,
            }
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.widget.textbox,
                id = "loader-textbox",
                text = "PLACEHOLDER",
                font = "Arial 12"

            }
        },
    }
}

local loader_arc = loader.widget.primary:get_children_by_id("loader-arc")[1]
local loader_textbox = loader.widget.primary:get_children_by_id("loader-textbox")[1]

-- blank on non-primary screens
loader.widget.alternate = nil

function loader.init()
    local primary = screen.primary

    ---@param s Awesome.Screen
    awful.screen.connect_for_each_screen(function(s)
        local is_primary = s == primary

        ---@diagnostic disable-next-line:inject-field
        s.loader = wibox {
            x = s.geometry.x,
            y = s.geometry.y,
            width = s.geometry.width,
            height = s.geometry.height,

            screen = s,

            ontop = true,
            visible = false,

            ---@type Awesome.Client.Type
            type = "splash",

            bg = LOADER_BG_COLOR,

            widget = is_primary and loader.widget.primary or loader.widget.alternate
        }
    end)

    loader.timer = Timer({
        timeout = 1 / 30,
        callback = loader.idle
    })
end

local max = math.max
local abs = math.abs

-- rotate once every second
local step = 100 / 30
local bar_len = 0
function loader.idle()
    local value = loader_arc.values[1] + loader_arc.values[2]

    value = value - step
    value = value % 100

    -- bar changes at half pace compared to rotation
    bar_len = bar_len - step / 2
    -- max 75, min -75 means large to small is smooth.
    if bar_len <= -100 then
        bar_len = 100
    end 

    local bar_length = abs(bar_len)

    local overlap = max(0, (value + bar_length) - 100)

    -- overlap fixes clipping when value + bar_len >= 100
    loader_arc.values = { overlap, value - overlap, bar_length - overlap }
end

---@param reason string?
function loader.start(reason)
    loader_textbox.text = reason or "Loading"

    for s in screen do
        ---@diagnostic disable-next-line:undefined-field
        s.loader.visible = true
    end

    if not loader.timer.started then
        loader.timer:start()
    end
end

function loader.stop()
    for s in screen do
        ---@diagnostic disable-next-line:undefined-field
        s.loader.visible = false
    end

    if loader.timer.started then
        loader.timer:stop()
    end
end

loader.init()

return loader
