local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local no_scroll = require("src.widgets.helper.no_scroll")

local config = require("config")

local notif_constants = require("src.notify.constants")

local notification = require("src.widgets.notify.notification")

-- TODO some wibox with a truly transparent background
local function create_notification_area()
    local list = wibox.widget {
        layout = wibox.layout.fixed.vertical,

        spacing = 15
    }

    local primary_screen = screen.primary

    local width = notif_constants.size.width

    local x = primary_screen.workarea.width / 2 - width / 2

    -- create a popup in the top center
    local _ = awful.popup {
        ontop     = true,
        visible   = true,
        widget    = list,
        bg        = "#ffffff00",
        
        width = width,
        x = x,
        y = config.taskbar.top + config.gap,
    }

    local function remove_dead_notifs()
        for index, widget in ipairs(list:get_all_children()) do
            if widget.lifespan <= 0 then
                list:remove(index)
            end
        end
    end

    gears.timer {
        timeout   = notif_constants.cycle_time_in_seconds,
        autostart = true,
        callback  = function()
            for index, widget in ipairs(list:get_all_children()) do
                -- seems to help after a system sleep
                if not widget.lifespan then
                    widget.lifespan = config.notification_lifespan / notif_constants.cycle_time_in_seconds
                end

                widget.lifespan = widget.lifespan - 1


                if widget.lifespan <= 0 then
                    list:remove(index)
                else
                    if widget.get_children_by_id ~= nil then
                        local progress = widget:get_children_by_id("progress")[1]

                        if progress then
                            progress.value = widget.lifespan
                        end
                    end
                end
            end
        end
    }

    return list, remove_dead_notifs
end

local notification_area, remove_dead_notifs = create_notification_area()

-- TODO not super clean
-- TODO notification sound?
local function notification_popup(args)
    local notif, close_button = notification(args, screen.primary)

    local lifespan = config.notification_lifespan / notif_constants.cycle_time_in_seconds

    notif.lifespan = lifespan

    close_button:connect_signal("button::press", no_scroll(function()
        notif.lifespan = 0

        remove_dead_notifs()
    end))

    notification_area:add(notif)
end



return notification_popup