local rofi = require("src.sh").rofi
local wibox = require("wibox")
local no_scroll = require("src.widgets.helper.function.no_scroll")

local get_icon = require("src.util.fs.get_icon")

local wal_svg = require("src.widgets.element.wal_svg")

local function create_launcher()
    local button = wibox.widget {
        image = get_icon("apps.svg"),
        resize = true,
        widget = wal_svg,
        replace = "white",
    }

    button:connect_signal("button::press", no_scroll(function()
        rofi()
    end))

    return button
end

return create_launcher
