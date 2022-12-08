local wibox  = require("wibox")
local awful  = require("awful")
local gtimer = require("gears.timer")

-- awful.widget.watch but return the timer as the second argument
---@param command string
---@param timeout number?
---@param callback (fun(widget: table, stdout: string, stderr: string, exitreason: string, exitcode: integer))?
---@param widget table?
local function watch_widget(command, timeout, callback, widget)
    timeout = timeout or 5

    callback = callback or function(widget, stdout)
        widget.text = stdout
    end

    widget = widget or wibox.widget {
        widget = wibox.widget.textbox,
        text = "[Placeholder]"
    }

    local timer = gtimer {
        timeout   = timeout,
        autostart = true,
        call_now  = true,
        callback  = function()
            ---@param stdout string
            ---@param stderr string
            ---@param exitreason string
            ---@param exitcode integer
            awful.spawn.easy_async(command, function (stdout, stderr, exitreason, exitcode)
                callback(widget, stdout, stderr, exitreason, exitcode)
            end)
        end
    }

    return widget, timer
end

return watch_widget