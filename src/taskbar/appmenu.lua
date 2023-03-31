local config         = require("config")
local wal            = require("src.util.wal")

local appmenu_widget = require("src.appmenu.widget")
local get_font       = require("src.util.get_font")

local wibox          = require("wibox")

local function create_appmenu()
    if not config.gimmicks.global_menu then
        return
    end

    return appmenu_widget({
        button_template = function()
            local widget = wibox.widget {
                layout = wibox.container.background,
                {
                    layout = wibox.container.margin,
                    margins = 2,
                    {
                        widget = wibox.widget.textbox,
                        font = get_font(13),
                        id = "text-role"
                    }
                }
            }

            wal.on_change(function(scheme)
                widget.fg = scheme.special.foreground
            end)

            return widget
        end,
        menu_template = {
            vertical = function()
                local widget = wibox.widget {
                    layout = wibox.container.background,
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            widget = wibox.widget.textbox,
                            forced_width = 32
                        },
                        {
                            layout = wibox.layout.fixed.vertical,
                            spacing = 2,
                            id = "menu-role"
                        },
                    }
                }

                return widget
            end
        }
    })
end

return create_appmenu
