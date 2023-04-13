local awful  = require("awful")
local wibox  = require("wibox")
local atk    = require("src.widgets.helper.applet.toolkit")
local config = require("config")
local spairs = require("src.util.spairs")

local function color_band(color_list)
    local widgets = {
        layout = wibox.layout.flex.horizontal,
        spacing = 5
    }

    for k, color in spairs(color_list) do
        table.insert(widgets, {
            {
                {
                    layout = wibox.container.margin,
                    margins = 16,
                },
                layout = wibox.container.background,
                bg = color,
            },
            {
                atk.tiny(tostring(k)),
                layout = wibox.container.place,
            },

            spacing = 2,
            layout = wibox.layout.fixed.vertical,
        })
    end

    return widgets
end

local function create_awesome_info()
    local awesome_info = wibox.widget {
        atk.title("Window Manager"),

        {
            {
                {
                    atk.subtitle("Awesome Version"),

                    atk.id_text("awesome-version", atk.font_size.TINY),

                    layout = wibox.layout.fixed.vertical
                },

                {
                    atk.subtitle("Font"),
                    atk.body(config.font),

                    layout = wibox.layout.flex.horizontal,
                },

                {
                    atk.subtitle("Compositor"),
                    atk.body(tostring(awesome.composite_manager_running)),

                    layout = wibox.layout.flex.horizontal,
                },

                {
                    atk.subtitle("Gimmicks"),

                    (function()
                        local widgets = {
                            layout = wibox.layout.fixed.vertical
                        }

                        for k, v in pairs(config.gimmicks) do
                            table.insert(
                                widgets,
                                {
                                    atk.tiny(" • " .. tostring(k)),
                                    atk.tiny(v ~= false and "Enabled" or "Disabled"),

                                    layout = wibox.layout.flex.horizontal
                                }
                            )
                        end

                        return widgets
                    end)(),

                    layout = wibox.layout.fixed.vertical,
                },

                layout = wibox.layout.fixed.vertical,
                spacing = 5,
            },

            {
                {
                    atk.subtitle("Colors"),

                    atk.body("Window Decorations"),

                    color_band(config.decorations.colors),

                    atk.body("Tag Colors"),

                    color_band(config.tag),

                    atk.body("Button Colors"),

                    color_band(config.button),

                    atk.body("Progress Bar Colors"),

                    color_band(config.progressbar),

                    layout = wibox.layout.fixed.vertical,

                    forced_width = 256,
                },


                layout = wibox.layout.fixed.vertical,
                spacing = 5,
            },
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
        },

        atk.button("Launch Logger", function ()
            awful.spawn.with_shell(string.format("%s -e \"tail -f /proc/$(pidof awesome)/fd/2\"", config.apps.terminal))
        end),

        layout = wibox.layout.fixed.vertical,
        spacing = 5,
    }

    awful.spawn.easy_async("awesome -v", function(stdout)
        awesome_info:get_children_by_id("awesome-version")[1].text = stdout
    end)

    return awesome_info
end

return create_awesome_info
