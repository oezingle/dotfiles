local wibox     = require("wibox")
local config    = require("config")
local shapes    = require("util.shapes")
local get_font  = require("util.get_font")
local no_scroll = require("widgets.helper.no_scroll")

--- Create an item for a radial menu without the thinking part
---@param name string
---@param icon string
local function easy_menu_item(name, icon)
    local menu_item = wibox.widget {
        {
            {
                {
                    {
                        widget        = wibox.widget.imagebox,
                        image         = icon,
                        forced_width  = 64,
                        forced_height = 64,
                    },
                    {
                        {
                            widget = wibox.widget.textbox,
                            font   = get_font(12),
                            markup = name,
                        },
                        layout = wibox.container.place,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.container.place,

                forced_width = 96,
                forced_height = 96,
            },

            layout = wibox.container.margin,
            margins = 10,
        },
        layout = wibox.container.background,

        bg = config.button.normal,
        shape = shapes.rounded_rect(100),
    }

    menu_item:connect_signal("mouse::enter", function(w)
        w.bg = config.button.hover
    end)

    menu_item:connect_signal("mouse::leave", function(w)
        w.bg = config.button.normal
    end)

    menu_item:connect_signal("button::press", no_scroll(function(w)
        w.bg = config.button.active
    end))

    return menu_item
end

return easy_menu_item
