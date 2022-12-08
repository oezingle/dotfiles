
local gears = require("gears")

-- create a widget that updates itself
local function update_widget (args)     
    local widget = args.widget

    if args.update_callback then
        local timer = gears.timer {
            timeout   = args.timeout or 10,
            call_now  = true,
            autostart = true,
            callback  = function()
                if not widget.visible then
                    return
                end

                args.update_callback(widget)
            end
        }
    end

    return widget
end

return update_widget