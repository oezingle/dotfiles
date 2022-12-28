local applet           = require("src.widgets.helper.applet")
local atk              = require("src.widgets.helper.applet.toolkit")
local wallpaper_widget = require("src.widgets.applet.choose_wallpaper.wallpaper_widget")
local wibox            = require("wibox")
local get_font         = require("src.util.get_font")
local config           = require("config")
local shapes           = require("src.util.shapes")
local no_scroll        = require("src.widgets.helper.no_scroll")

local wallpaper = require("src.util.wallpaper")

local function create_choose_wallpaper()

    local grid = wibox.widget {
        layout = wibox.layout.grid,

        forced_num_cols = 3,

        spacing = 5,

        min_cols_size = 163,
        min_rows_size = 92
    }

    for _, identifier in ipairs(wallpaper.all_identifiers()) do
        local button = wibox.widget {
            {
                {
                    {
                        widget = wallpaper_widget,

                        radius = 10,

                        identifier = identifier,

                        forced_width = 163,
                        forced_height = 92
                    },
                    {
                        layout = wibox.container.place,
                        {
                            widget = wibox.widget.textbox,
                            font = get_font(10),

                            text = tostring(identifier)
                        }
                    },
                    layout = wibox.layout.fixed.vertical,
                    spacing = 5
                },
                layout = wibox.container.margin,
                margins = 2,
            },
            layout = wibox.container.background,

            bg = config.button.normal,

            shape = shapes.rounded_rect()
        }

        button:connect_signal("mouse::enter", function(w)
            w.bg = config.button.hover
        end)
        button:connect_signal("mouse::leave", function(w)
            if identifier == wallpaper.get_current_identifier() then
                w.bg = config.button.active
            else
                w.bg = config.button.normal
            end
        end)

        awesome.connect_signal("wallpaper_changed", function()
            if identifier == wallpaper.get_current_identifier() then
                button.bg = config.button.active
            else
                button.bg = config.button.normal
            end
        end)

        button:connect_signal("button::press", no_scroll(function()
            wallpaper.set_identifier(identifier)
        end))

        grid:add(button)
    end

    local widget = wibox.widget {
        atk.title("Select Wallpaper"),

        grid,

        layout = wibox.layout.fixed.vertical,
        spacing = 5,

        forced_width = 512,
    }

    return widget
end

ChooseWallpaper = applet(create_choose_wallpaper()):create()
