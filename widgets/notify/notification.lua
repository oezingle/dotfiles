local wibox  = require("wibox")
local shapes = require("util.shapes")

local get_font             = require("util.get_font")
local get_decoration_color = require("util.color.get_decoration_color")

local arbitrary_icon = require("widgets.components.arbitrary_icon")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local config = require("config")

local notif_constants = require("notify.constants")

-- Builder for notification wibox
-- TODO I don't get how args.actions works
local function notification(args, s, is_notif_center)
    is_notif_center = is_notif_center or false

    if not s then
        s = screen.primary
    end

    local close_button = wibox.widget {
        image = config_dir .. "icon/titlebar/focus/close.svg",
        widget = wibox.widget.imagebox,

        forced_width = notif_constants.size.close_button,
        forced_height = notif_constants.size.close_button,

        id = "close-button"
    }

    local icon_widget

    if args.icon then
        local icon = args.icon

        if icon:sub(1, 1) == "/" then
            icon_widget = {
                image = icon,
                widget = wibox.widget.imagebox,
            }
        else
            icon_widget = {
                widget = arbitrary_icon,
                icon_name = icon
            }
        end
    end

    local widget = wibox.widget {
        {
            {
                {
                    close_button,
                    {
                        {
                            {
                                widget = wibox.widget.progressbar,

                                value = config.notification_lifespan / notif_constants.cycle_time_in_seconds,
                                min_value = 0,
                                max_value = config.notification_lifespan / notif_constants.cycle_time_in_seconds,

                                id = "progress",

                                shape = shapes.rounded_rect(),

                                color = config.popup.fg,
                                background_color = config.popup.bg,
                            },
                            widget = wibox.container.rotate,
                            direction = "east",

                            id = "progress-container",

                            forced_width = 2,
                            forced_height = 96,
                        },
                        layout = wibox.container.place,
                        halign = "left"
                    },
                    layout = wibox.layout.fixed.vertical
                },
                {
                    {
                        icon_widget,

                        layout = wibox.container.place,
                        valign = 'center',
                        halign = 'center',

                        forced_height = args.icon and 64 or 0,
                        forced_width = args.icon and 64 or 0,
                    },
                    widget = wibox.container.margin,
                    right = args.icon and 5 or 0,
                    left = args.icon and 5 or 0
                },

                {
                    {
                        text = args.title or args.appname,
                        font = get_font(12),
                        widget = wibox.widget.textbox,

                        forced_height = notif_constants.size.close_button,
                    },
                    {
                        text = args.text,
                        font = get_font(10),
                        widget = wibox.widget.textbox,

                        id = "notification-text"
                    },
                    layout = wibox.layout.fixed.vertical
                },
                layout = wibox.layout.fixed.horizontal
            },
            widget = wibox.container.margin,
            margins = 5,
        },
        widget = wibox.container.background,

        shape = shapes.rounded_rect(),

        bg = is_notif_center and config.button.normal or config.popup.bg,
        fg = config.popup.fg,

        shape_border_width = not is_notif_center and config.border.floating_width,
        shape_border_color = not is_notif_center and get_decoration_color(),

        forced_width = notif_constants.size.width,
    }

    -- TODO make height of progress consider icon height

    local notification_text = widget:get_children_by_id("notification-text")[1]

    local new_height = notification_text:get_height_for_width(notif_constants.size.width - notif_constants.size.close_button, s)

    notification_text.forced_height = new_height

    local progress_container = widget:get_children_by_id("progress-container")[1]

    progress_container.forced_height = new_height

    return widget, close_button
end

return notification
