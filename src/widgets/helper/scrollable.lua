local wibox    = require("wibox")
local config   = require("config")
local shapes   = require("src.util.shapes")
local gcolor   = require("gears.color")
local pannable = require("src.widgets.helper.pannable")

local bind_width_and_height = require("src.widgets.helper.function.bind_width_and_height")
local get_preferred_size = require("src.widgets.helper.function.get_preferred_size")

-- user scrollable widget using mouse button 4/5 signals

-- weak table to hold last bar_height. if bar_height exists and is the same, ignore background change
local scrollbar_cache = setmetatable({}, {
    __mode = "k"
})

-- Amount to scroll in pixels
local SCROLL_AMOUNT = 20

--- create bar background using a scuffed gradient
---comment
---@param bar table bar widget
---@param content table scrolled widget
---@param scroll number scroll px
---@return Color|nil
local function generate_background(bar, content, scroll)
    local _, content_height = get_preferred_size(content)

    local bar_height = bar.height / content_height

    local scroll_offset = scroll / content_height

    local cached = scrollbar_cache[content]

    if cached and cached.bar_height == bar_height and cached.scroll_offset == scroll_offset then
        return nil
    end

    scrollbar_cache[content] = {
        bar_height = bar_height,
        scroll_offset = scroll_offset
    }

    --[[
        height of light section = (bar height / content height) * bar height
        position of light section = (scroll / content height) * bar height
    ]]

    return gcolor {
        type = "linear",

        from = { 1, 0 },
        to   = { 1, bar.height },

        stops = {
            { 0, config.progressbar.bg },
            { scroll_offset, config.progressbar.bg },
            { scroll_offset, config.progressbar.fg },
            { scroll_offset + bar_height, config.progressbar.fg },
            { scroll_offset + bar_height, config.progressbar.bg }
        }
    }
end

-- TODO set scrollbar if child content changes height, but don't query child height. is there some signal for this perhaps?
-- connect signal widget::layout_changed (is that the signal?) -> query size

local function scrollable(child)
    local scroll_px = 0

    -- Bar to make the usre feel like they have any power
    local bar = wibox.widget {
        -- separator coming in clutch as a widget that expands
        widget = wibox.widget.separator,

        color = config.progressbar.fg,

        shape = shapes.rounded_rect(100),

        forced_width = 5,

        value = 0,
    }

    bind_width_and_height(bar)

    local child_w, child_h = get_preferred_size(child)

    local offset = wibox.layout {
        child,

        layout = pannable,

        forced_width  = child.forced_width or child_w,
        forced_height = child.forced_height or child_h
    }

    local function set_scroll_bar()
        local background = generate_background(bar, child, scroll_px)

        if background then
            bar.color = background
        end
    end

    local function set_scroll()
        -- TODO cache this somehow
        local _, notif_list_height = get_preferred_size(child)

        if scroll_px < 0 then
            scroll_px = 0
        elseif scroll_px > notif_list_height - bar.height then
            scroll_px = notif_list_height - bar.height
        end

        offset:move({
            x = 0,
            y = -scroll_px
        })

        set_scroll_bar()
    end

    offset:connect_signal("button::press", function(data, lx, ly, button)
        if button == 4 or button == 5 then
            if button == 4 then
                scroll_px = scroll_px - SCROLL_AMOUNT
            elseif button == 5 then
                scroll_px = scroll_px + SCROLL_AMOUNT
            end

            set_scroll()
        end
    end)

    -- removed for speed
    -- pressing on the scroll bar sets the scroll position
    --[[
    for _, signal in ipairs({
        "button::press",
        "button::release"
    }) do
        bar:connect_signal(signal, function(data, lx, ly, button)
            if button == 1 then
                local bar_height = bar.height

                local _, notif_list_height = get_preferred_size(child)

                scroll_px = notif_list_height * (ly / bar_height)

                set_scroll()
            end
        end)
    end
    ]]

    local widget = wibox.widget {
        offset,
        bar,
        layout = wibox.layout.fixed.horizontal,
        spacing = 5
    }

    return widget
end

return scrollable
