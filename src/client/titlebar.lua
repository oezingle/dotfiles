local gears = require("gears")
local awful = require("awful")
local should_show_titlebars = require("src.util.client.should_show_titlebars")

local gfs = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local wibox = require("wibox")

local config = require("config")

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
    -- TODO hover button svgs, and desaturate unfocus buttons
    --close_button:connect_signal("mouse::enter", function (w)
    --    w.image = config_dir.."icon/titlebar/hover/close.svg"
    --end)
    --close_button:connect_signal("mouse::leave", function (w)
    --    w.image = config_dir.."icon/titlebar/focus/close.svg"
    --end)

    local minimize_button = awful.titlebar.widget.minimizebutton(c)
    local maximized_button = awful.titlebar.widget.maximizedbutton(c)

    awful.titlebar(
        c, 
        {
            position = config.decorations.titlebar.pos,
            bg_normal = c.decoration_color,
            bg_focus = c.decoration_color
        }
    ) : setup {
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