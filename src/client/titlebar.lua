local gears = require("gears")
local awful = require("awful")
local should_show_titlebars = require("src.util.client.should_show_titlebars")

local wibox = require("wibox")

local config = require("config")
local get_icon = require("src.util.fs.get_icon")

local ensure_client_decoration = require("src.client.colorize")

client.connect_signal("request::titlebars", function(c)
    ensure_client_decoration(c)

    c.has_titlebar = true

    local buttons = gears.table.join(
        awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    local close_button = awful.titlebar.widget.closebutton(c)
    close_button:connect_signal("mouse::enter", function(w)
        w.image = get_icon("titlebar/focus/close.svg")
    end)
    close_button:connect_signal("mouse::leave", function(w)
        w.image = get_icon("titlebar/unfocus/close.svg")
    end)

    local minimize_button = awful.titlebar.widget.minimizebutton(c)
    minimize_button:connect_signal("mouse::enter", function(w)
        w.image = get_icon("titlebar/focus/min.svg")
    end)
    minimize_button:connect_signal("mouse::leave", function(w)
        w.image = get_icon("titlebar/unfocus/min.svg")
    end)

    local maximized_button = awful.titlebar.widget.maximizedbutton(c)
    maximized_button:connect_signal("mouse::enter", function(w)
        if c.maximized then
            w.image = get_icon("titlebar/focus/max_active.svg")
        else
            w.image = get_icon("titlebar/focus/max_inactive.svg")
        end
    end)
    maximized_button:connect_signal("mouse::leave", function(w)
        w.image = get_icon("titlebar/unfocus/max.svg")
    end)

    awful.titlebar(
        c,
        {
            position = config.decorations.titlebar.pos,
            bg_normal = c.decoration_color,
            bg_focus = c.decoration_color
        }
    ):setup {
        { -- Top
            close_button,
            minimize_button,
            maximized_button,

            layout = wibox.layout.fixed.vertical,
        },
        { -- Middle
            buttons = buttons,
            layout = wibox.layout.fixed.vertical
        },
        { -- Bottom
            buttons = buttons,
            layout  = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.align.vertical
    }

    if not should_show_titlebars(c) then
        awful.titlebar.hide(c, config.decorations.titlebar.pos)
    end
end)
