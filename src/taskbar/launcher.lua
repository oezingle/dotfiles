local rofi = require("src.sh").rofi
local wibox = require("wibox")
local no_scroll = require("src.widgets.helper.no_scroll")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local function create_launcher()
    local button = wibox.widget {
        image = config_dir .. "icon/apps.svg",
        resize = true,
        widget = wibox.widget.imagebox
    }

    button:connect_signal("button::press", no_scroll(function()
        rofi()
    end))

    return button
end

return create_launcher
