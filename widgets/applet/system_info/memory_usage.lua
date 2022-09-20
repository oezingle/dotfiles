local awful    = require("awful")
local wibox    = require("wibox")
local shapes   = require("util.shapes")
local config   = require("config")
local get_font = require("util.get_font")

---@param string string
---@return string[] words
local function split(string)
    local words = {}

    for word in string:gmatch("%w+") do
        table.insert(words, word)
    end

    return words
end

--- Get the correct suffix for the amount of data you have (eg, KiB, MiB, GiB)
---@param number number
---@return number divided, string suffix
local function get_data_size_suffix(number)
    local suffixes = {
        "K",
        "M",
        "G",
        "T",
        "P"
    }

    local divides = 0

    while number > 1024 do
        number = number / 1024

        divides = divides + 1
    end

    -- change "B" to "iB" if you're a FUCKING NERD
    return math.ceil(number), suffixes[divides + 1] .. "B"
end

---@param swap boolean?
local function memory_usage(swap)
    local row = swap and 3 or 2

    local free = "free | awk 'NR==" .. tostring(row) .. "{printf $2; printf \" \"; printf $3}'"

    local cmd = 'bash -c "' .. free:gsub("\"", "\\\"") .. '"'

    local usage = wibox.widget {
        widget = wibox.widget.textbox,
        font = get_font(10),
        text = "000%",
    }

    local progress = awful.widget.watch(
        cmd,
        1,
        function(widget, stdout)
            local words = split(stdout)

            local total = tonumber(words[1])
            local used = tonumber(words[2])

            usage.text = tostring(math.floor((used / total) * 100)) .. "%"

            widget.max_value = total
            widget.value = used
        end,
        wibox.widget {
            widget = wibox.widget.progressbar,

            max_value = 1,
            min_value = 0,
            value = 0.5,

            -- TODO don't force this value
            forced_width = 320,
            forced_height = 2,

            shape = shapes.rounded_rect(),
            background_color = config.progressbar.bg,
            color = config.progressbar.fg,
        }
    )

    local progress_and_text = wibox.widget {
        {
            {
                widget = wibox.widget.textbox,
                font = get_font(10),
                text = "0?B",

                id = "memory-zero-text"
            },
            {
                {
                    progress,
                    layout = wibox.container.place
                },
                layout = wibox.container.margin,
                left = 5,
                right = 5
            },
            {
                {
                    widget = wibox.widget.textbox,
                    font = get_font(10),
                    text = "0?B",

                    id = "memory-total-text",
                },
                layout = wibox.container.place,
                halign = "right"
            },

            layout = wibox.layout.align.horizontal,
        },
        nil,
        usage,
        layout = wibox.layout.align.horizontal,

        -- TODO expand = "outside" makes the layout act as a stack
    }

    awful.spawn.easy_async(cmd, function(stdout)
        local words = split(stdout)

        --- if total is nil we're fucked who gives a shit man
        local total = tonumber(words[1]) --[[@as number]]

        local total_divided, suffix = get_data_size_suffix(total)

        local zero_text = progress_and_text:get_children_by_id("memory-zero-text")[1]
        zero_text.text = "0" .. suffix

        local total_text = progress_and_text:get_children_by_id("memory-total-text")[1]
        total_text.text = tostring(total_divided) .. suffix
    end)

    return progress_and_text
end

return memory_usage
