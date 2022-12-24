local wibox = require("wibox")
local awful = require("awful")
local no_scroll = require("src.widgets.helper.no_scroll")

local config = require("config")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local shapes               = require("src.util.shapes")
local get_decoration_color = require("src.util.color.get_decoration_color")

local function exitable_dialog_box(args)
    local close_button = wibox.widget {
        widget = wibox.widget.imagebox,
        image = config_dir .. "icon/titlebar/unfocus/close.svg",

        forced_width = 24,
        forced_height = 24,
    }

    close_button:connect_signal("mouse::enter", function(w)
        w.image = config_dir .. "icon/titlebar/focus/close.svg"
    end)
    close_button:connect_signal("mouse::leave", function(w)
        w.image = config_dir .. "icon/titlebar/unfocus/close.svg"
    end)

    local decoration_color = args.bg or get_decoration_color()

    local widget = wibox.widget {
        {
            {
                {
                    {
                        close_button,
                        widget = wibox.container.margin,
                        left = 2,
                        top = 2,
                        right = 2,
                    },
                    widget = wibox.container.background,
                    bg = decoration_color,
                },
                {
                    {
                        args.widget,
                        widget = wibox.container.margin,
                        margins = 5,
                    },
                    widget = wibox.container.background,
                    shape = shapes.rounded_rect()
                },
                layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.margin,
            margins = config.border.floating_width,
        },
        widget = wibox.container.background,
        shape = shapes.rounded_rect(),

        shape_border_color = decoration_color,
        shape_border_width = config.border.floating_width,
    }

    return widget, close_button
end

local function exitable_dialog(args)
    local decoration_color = args.bg or get_decoration_color()

    local widget, close_button = exitable_dialog_box {
        bg = decoration_color,
        widget = args.widget
    }

    local popup = awful.popup {
        widget = widget,

        visible = args.visible or false,

        bg = config.popup.bg,
        fg = config.popup.fg,

        shape = shapes.rounded_rect(),

        ontop = true,

        placement = args.placement or awful.placement.centered,
    }

    close_button:connect_signal("button::press", no_scroll(function(w)
        popup.visible = false

        if args.on_close then
            args.on_close()
        end
    end))

    return popup, close_button
end

return exitable_dialog
