local awful              = require("awful")
local wibox              = require("wibox")
local gears              = require("gears")
local clienticon_or_xorg = require("src.widgets.components.clienticon_or_xorg")

local arbitrary_icon = require("src.widgets.components.arbitrary_icon")

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

local function create_tasklist(s)
    return awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = tasklist_buttons,
        layout          = {
            layout = wibox.layout.fixed.vertical,
            halign = "center"
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    widget = clienticon_or_xorg,

                    id = "icon"
                },
                margins = 1,
                widget  = wibox.container.margin
            },
            nil,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                if not c.skip_taskbar then
                    self:get_children_by_id("icon")[1].client = c

                    -- TODO memory leak??
                    local tooltip = awful.tooltip {
                        objects = { self },
                        text = c.name
                    }
                end
            end,
            layout = wibox.layout.align.vertical,
        },
    }
end

return create_tasklist
