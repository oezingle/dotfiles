local radial_menu      = require("widgets.util.radial_menu")
local scratch_terminal = require("util.scratch").terminal
local shapes           = require("util.shapes")
local get_font         = require("util.get_font")
local config           = require("config")
local no_scroll        = require("widgets.helper.no_scroll")

local wibox      = require("wibox")
local gfs        = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local function scratch_terminal_widget()

    -- TODO icons
    local langs = {
        {
            name = "Bash",
            cmd  = "bash",
            icon = "terminal-outline"
        },

        {
            name = "Python",
            cmd  = "python",
            icon = "logo-python"
        },

        {
            name = "Node",
            cmd  = "node",
            icon = "logo-nodejs"
        },

        {
            name = "Lua",
            cmd  = "lua",
            icon = nil
        },

        {
            name = "BC",
            cmd  = "bc",
            icon = "calculator-outline"
        },
    }

    local children = {}

    for _, lang in ipairs(langs) do
        lang.icon = lang.icon or "help-circle-outline"

        local icon = config_dir .. "icon/scratch-term/" .. lang.icon .. ".svg"

        local lang_widget = wibox.widget {
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
                                text   = lang.name,
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

        lang_widget:connect_signal("mouse::enter", function (w)
            w.bg = config.button.hover
        end)

        lang_widget:connect_signal("mouse::leave", function (w)
            w.bg = config.button.normal
        end)

        lang_widget:connect_signal("button::press", no_scroll(function (w)
            w.bg = config.button.active
        end))
        
        table.insert(children, {
            widget = lang_widget,

            callback = function()
                scratch_terminal(lang.cmd)
            end
        })
    end

    radial_menu(children, true)
end

return scratch_terminal_widget
