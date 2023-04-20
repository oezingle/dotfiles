
local naughty = require("naughty")

local notification_popup = require("src.notify.popup")
local is_do_not_disturb = require("src.notify.do_not_disturb").get_state

require("src.widgets.components.notify.center")

local function on_notify(args)
    if not is_do_not_disturb() then
        notification_popup(args)
    end

    NotificationCenter.notify(args)

    -- seems to be required
    return {}
end

-- suspend awesome's notifications so I can roll my own
naughty.suspend()

naughty.config.notify_callback = on_notify