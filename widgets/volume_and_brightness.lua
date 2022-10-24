-- TODO move to widgets

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local config = require("config")
local get_font = require("util.get_font")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local shapes = require("util.shapes")

local function get_volume(callback)
    awful.spawn.easy_async_with_shell(
        "pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \\([0-9][0-9]*\\)%.*,\\1,'"
        ,
        function(volume)
            local vol = tonumber(volume)

            if vol > 100 then
                -- cap volume at 100%
                awful.spawn("pactl -- set-sink-volume 0 100%")
                callback(100)
            else
                callback(vol)
            end
        end
    )
end

local function get_brightness(callback)
    awful.spawn.easy_async(
        "xbacklight -get",
        function(returned)
            local brightness = tonumber(returned)

            if brightness <= 1 then
                -- screen going black is super annoying
                callback(0)
            else
                callback(brightness)
            end
        end
    )
end

local popup = awful.popup {
    widget    = {
        {
            {
                {
                    widget = wibox.widget.textbox,
                    text   = "Progress Popup",
                    font   = get_font(18),

                    id = "popup-text",
                },
                widget = wibox.container.background,
                fg = "#fff"
            },
            {
                widget        = wibox.widget.imagebox,
                -- resize image
                resize        = true,
                forced_height = 160,
                forced_width  = 160,

                id = "popup-image",
            },
            {
                max_value        = 100,
                value            = 33,
                forced_height    = 10,
                forced_width     = 160,
                background_color = config.progressbar.bg,
                color            = config.progressbar.fg,
                shape            = shapes.rounded_rect(),
                widget           = wibox.widget.progressbar,

                id = "popup-progress"
            },
            layout = wibox.layout.fixed.vertical
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    visible   = false,
    ontop     = true,
    bg        = config.popup.bg,
    shape     = shapes.rounded_rect(),
    placement = awful.placement.centered,
}

local timer = gears.timer({
    timeout     = 2,
    single_shot = true,
    callback    = function()
        popup.visible = false
    end
})

-- Getter method for when this hacky method inevitably breaks
local get_widget = function(id)
    return popup.widget:get_children_by_id(id)[1]
end

-- Function that runs a command without any args
local cmd_callback = function(cmd, callback, shell)
    shell = shell or false

    -- determine function used. Some might need a shell
    local spawn_function = shell and awful.spawn.easy_async_with_shell or awful.spawn.easy_async

    return function()
        spawn_function(
            cmd,
            callback
        )
    end
end

local volume_changed = function()
    get_volume(function(volume)
        get_widget("popup-text").text = "Volume"
        get_widget("popup-progress").value = volume

        local svg_path = ""

        if volume > 66 then
            svg_path = "volume-high-outline.svg"
        elseif volume > 33 then
            svg_path = "volume-medium-outline.svg"
        elseif volume > 0 then
            svg_path = "volume-low-outline.svg"
        else
            svg_path = "volume-mute-outline.svg"
        end

        get_widget("popup-image").image = config_dir .. "icon/volume/" .. svg_path

        popup.visible = true

        popup.screen = awful.screen.focused()

        timer:again()
    end)
end

local brightness_changed = function()
    get_brightness(function(brightness)
        get_widget("popup-text").text = "Brightness"
        get_widget("popup-progress").value = brightness

        get_widget("popup-image").image = config_dir .. "icon/sunny-outline.svg"

        popup.visible = true

        popup.screen = awful.screen.focused()

        timer:again()
    end)
end

local keys = {
    awful.key({}, "XF86AudioRaiseVolume",
        cmd_callback("pactl -- set-sink-volume 0 +10%", volume_changed)
    ),
    awful.key({}, "XF86AudioLowerVolume",
        cmd_callback("pactl -- set-sink-volume 0 -10%", volume_changed)
    ),
    -- TODO proper mute/unmute toggle
    awful.key({}, "XF86AudioMute",
        cmd_callback("pactl -- set-sink-volume 0 0%", volume_changed)
    ),

    awful.key({}, "XF86MonBrightnessDown",
        cmd_callback(config_dir .. "sh/brightness.sh sub 10", brightness_changed)
    ),
    awful.key({}, "XF86MonBrightnessUp",
        cmd_callback(config_dir .. "sh/brightness.sh add 10", brightness_changed)
    ),

}

return {
    keys = keys
}
