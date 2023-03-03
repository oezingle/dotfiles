local awful         = require("awful")
local wibox         = require("wibox")
local no_scroll     = require("src.widgets.helper.no_scroll")
local config        = require("config")
local get_font      = require("src.util.get_font")
local scratch       = require("src.util.scratch")

---@alias StatusSet table<number, string>

---@enum StatusSets
local status_sets   = {
    ---@type StatusSet
    emoji_sad = {
            [10] = "😴",
            [25] = "🥶",
            [35] = "🙁",
            [60] = "😦",
            [75] = "😥",
            [90] = "🔥",
            [100] = "💯",
    },
    ---@type StatusSet
    emoji_mad = {
            [10] = "😴",
            [25] = "🥶",
            [35] = "😬",
            [60] = "😠",
            [75] = "😡",
            [90] = "🔥",
            [100] = "💯",
    },
    ---@type StatusSet
    emoticon = {
            [25] = ":)",
            [50] = ":|",
            [75] = ":(",
            [100] = ">:(",
    },
    ---@type StatusSet
    numbers = {
            [10] = "0.1",
            [20] = "0.2",
            [30] = "0.3",
            [40] = "0.4",
            [50] = "0.5",
            [60] = "0.6",
            [70] = "0.7",
            [80] = "0.8",
            [90] = "0.9",
            [100] = "1.0"
    }
}

local load_statuses = status_sets.emoji_mad

local function create_system_status()
    local widget = awful.widget.watch(
        "/bin/bash -c \"echo \\\"scale=10; $(uptime | awk -F '[,:]' '{print $(NF-2)}') / $(grep -c ^processor /proc/cpuinfo)\\\" | bc\""
        ,
        2,
        function(widget, stdout)
            -- constrained to 100 in order to not break the widget
            local load = math.min((tonumber(stdout) or 0) * 100, 100)

            local closest_status
            for status_time, _ in pairs(load_statuses) do
                if status_time >= load and (not closest_status or closest_status > status_time) then
                    closest_status = status_time
                end
            end

            widget:get_children()[1].text = load_statuses[closest_status] or "[!]"

            -- widget.text = tostring(math.floor(load)) .. "%"
        end,

        -- TODO square layout based on width
        wibox.widget {
            layout = wibox.container.place,
            forced_width = config.taskbar.left,
            {
                widget = wibox.widget.textbox,
                font = get_font(14)
            }
        }
    )

    widget:connect_signal("button::press", no_scroll(function()
        scratch.terminal("top", true)
    end))

    return widget
end

local system_status = create_system_status()

return function()
    return system_status
end
