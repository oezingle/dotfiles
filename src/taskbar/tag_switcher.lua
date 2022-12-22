local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local no_scroll = require("src.widgets.helper.no_scroll")
local wal       = require("src.util.wal")

local config = require("config")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function create_tag_switcher(screen)
    local style = {
        shape = gears.shape.circle,
        bg_occupied = config.tag.occupied,
        fg_occupied = "#fff",
        bg_focus = config.tag.focus,
        bg_empty = config.tag.empty,
        bg_urgent = config.tag.urgent
    }

    wal.on_change(function (scheme)
        style.bg_occupied = scheme.special.foreground
    end)

    screen.tag_switcher = awful.widget.taglist {
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,

        style = style,

        widget_template = {
            {
                -- this all just creates a circle. stupid but at least it works
                {
                    {
                        text = " ",
                        widget = wibox.widget.textbox,
                    },
                    margins = 5,
                    widget  = wibox.container.margin,
                },
                id     = 'background_role',
                widget = wibox.container.background,
            },
            left            = 2,
            right           = 2,
            widget          = wibox.container.margin,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                -- self:get_children_by_id('index_role')[1].markup = index
                self:connect_signal('mouse::enter', function()
                    local elem = self:get_children_by_id('background_role')[1]

                    elem.old_bg = elem.bg
                    elem.bg = config.tag.focus
                end)
                self:connect_signal("button::press", no_scroll(function()
                    -- remove old_bg as the focused background is the correct background for the indicator
                    local elem = self:get_children_by_id('background_role')[1]

                    elem.old_bg = nil
                end))
                self:connect_signal('mouse::leave', function()
                    local elem = self:get_children_by_id('background_role')[1]

                    if elem.old_bg then
                        elem.bg = elem.old_bg
                    end
                end)
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                --self:get_children_by_id('index_role')[1].markup = index
            end,
        },
    }
end

return create_tag_switcher