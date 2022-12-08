local wibox    = require("wibox")
local get_font = require("src.util.get_font")
local config   = require("config")
local watch_widget = require("src.widgets.util.watch_widget")

-- TODO stop/start timers

---@param core_number number
local function cpu_arc(core_number)
    local mpstat = "mpstat -P " .. tostring(core_number) .. " 1 1 | awk 'NR==4{print $13}'"

    local cmd = 'bash -c "' .. mpstat .. '"'

    -- TODO %usage below?

    return watch_widget(
        cmd,
        1,
        function(widget, stdout)
            widget.value = 100 - (tonumber(stdout) or 0)
        end,
        wibox.widget {
            {
                {
                    widget = wibox.widget.textbox,
                    markup = "<b>" .. tostring(core_number + 1) .. "</b>",
                    font = get_font(14)
                },
                layout = wibox.container.place
            },
            bg            = config.progressbar.bg,
            rounded_edge  = true,
            min_value     = 0,
            max_value     = 100,
            value         = 0,
            colors        = { config.progressbar.fg },
            widget        = wibox.container.arcchart,
            start_angle   = math.pi / 2,
            forced_width  = 48,
            forced_height = 48,
            thickness     = 8,
        }
    )
end

return cpu_arc
