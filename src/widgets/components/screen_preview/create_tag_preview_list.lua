local wibox = require("wibox")
local shapes = require("src.util.shapes")
local config = require("config")
local no_scroll = require("src.widgets.helper.function.no_scroll")

local get_font = require("src.util.get_font")

local tag_preview = require("src.widgets.components.screen_preview.tag_preview")
local get_tag_bg = require("src.widgets.components.screen_preview.get_tag_bg")

local function create_tag_preview_list(s, width, height)
    local list = s.screen_preview:get_children_by_id("tag-preview-list")[1]

    list:reset()

    local border_indicators = {}

    local tag_count = #s.tags

    for _, t in ipairs(s.tags) do
        local border_indicator = wibox.widget
        {
            {
                {
                    tag_preview(t, true),

                    forced_width = width / (tag_count + 2),
                    forced_height = height / (tag_count + 2),

                    layout = wibox.container.background,
                },

                layout = wibox.container.margin,
                margins = config.border.floating_width - 1,
            },

            layout = wibox.container.background,

            shape = shapes.rounded_rect(),
            shape_border_width = config.border.floating_width,
            shape_border_color = get_tag_bg(t),

            id = "tag-preview-border-indicator"
        }

        local widget = wibox.widget {
            layout = wibox.layout.fixed.vertical,
            border_indicator,
            {
                layout = wibox.container.place,
                {
                    widget = wibox.widget.textbox,

                    font = get_font(10),
                    text = "Tag " .. t.name
                }
            },

            -- Hidden widget with tag name stored
            {
                id = "tag-name",
                widget = wibox.widget.textbox,
                visible = false,

                text = t.name,
            },

            id = "tag-preview"
        }

        widget:connect_signal("mouse::enter", function()
            t:view_only()
        end)

        widget:connect_signal("button::press", no_scroll(function()
            s.screen_preview.old_tags = {}

            t:view_only()

            awesome.emit_signal("screen_preview::hide")
        end))

        border_indicators[t.name] = border_indicator

        list:add(widget)
    end

    return border_indicators
end

return create_tag_preview_list
