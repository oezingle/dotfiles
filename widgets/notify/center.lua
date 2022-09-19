local wibox     = require("wibox")
local shapes    = require("util.shapes")
local config    = require("config")
local autoclose = require("widgets.helper.autoclose")

local get_font             = require("util.get_font")
local get_decoration_color = require("util.color.get_decoration_color")
local notification         = require("widgets.notify.notification")
local no_scroll            = require("widgets.helper.no_scroll")

local datetime   = require("widgets.components.datetime")
local scrollable = require("widgets.util.scrollable")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

-- notification center

-- TODO fix scrollable
-- TODO save notifications to file, on awesome::exit, reload on startup

local notif_constants = require("notify.constants")

local primary_screen = screen.primary

local function create_notification_center(s)
    local list = wibox.widget {
        layout = wibox.layout.fixed.vertical,

        spacing = 15,

        forced_width = notif_constants.size.width,
    }

    local box_height = s.workarea.height * (4 / 5)

    local scroll_list = scrollable(list)

    local container = wibox {
        widget = wibox.widget {
            {
                {
                    widget = wibox.widget.textbox,
                    text = "Notifications",
                    font = get_font(14)
                },
                {
                    widget = wibox.container.margin,
                    left = 10,
                    right = 10,
                    bottom = 10,
                    scroll_list,
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 5
            },
            layout = wibox.container.margin,
            left = 5,
            top = 5,
            bottom = 5
        },

        ontop = true,

        bg = config.popup.bg,

        x = config.taskbar.left,
        y = ((s.workarea.height - config.taskbar.top) / 2) - (box_height / 2),

        shape = shapes.rounded_rect(),

        height = box_height,
        width = notif_constants.size.width + (2 * 10) + (2 * 5) + 5,

        border_width = config.border.floating_width,
        border_color = config.popup.border or get_decoration_color(),

        screen = s,
    }

    autoclose(container)

    return container, list
end

local notification_wibox, notification_list = create_notification_center(primary_screen)

local function clear_removed_notifs()
    for index, child in ipairs(notification_list:get_children()) do
        if child.visible == false then
            notification_list:remove(index)

            -- start again so the removed index doesn't break anything
            return clear_removed_notifs()
        end
    end
end

local function notify(args)
    local notif, close_button = notification(args, primary_screen, true)

    -- TODO datetime isn't a widget??
    --[[
    local widget = wibox.widget {
        {
            {
                widget = datetime,

                -- time = os.time(),

                id = "datetime"
            },

            layout = wibox.container.place
        },
        notif,

        layout = wibox.layout.fixed.vertical
    }
    ]]

    close_button:connect_signal("button::press", no_scroll(function()
        -- remove notification
        notif.visible = false

        clear_removed_notifs()
    end))

    notification_list:insert(1, notif)
end

-- TODO remove this - why should I provide a helper for this?
local function get_notification_center_button()
    -- TODO nifty stack with notification icon and notif count
    local button = wibox.widget {
        widget = wibox.widget.imagebox,
        image = config_dir .. "icon/notifications.svg"
    }

    button:connect_signal("button::press", no_scroll(function()
        NotificationCenter.toggle()
    end))

    return button
end

NotificationCenter = {
    hide = function()
        notification_wibox.visible = false

        clear_removed_notifs()
    end,

    show = function()
        clear_removed_notifs()

        notification_wibox.visible = true
    end,

    toggle = function()
        if notification_wibox.visible then
            NotificationCenter.hide()
        else
            NotificationCenter.show()
        end
    end,

    notify = notify
}

return {
    get_button = get_notification_center_button,
}
