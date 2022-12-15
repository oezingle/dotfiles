local awful           = require("awful")
local wibox           = require("wibox")
local config          = require("config")
local gears           = require("gears")
local system_status   = require("src.widgets.system_status")
local layout_selector = require("src.widgets.layout_selector")

local get_decoration_color = require("src.util.color.get_decoration_color")
local shapes = require("src.util.shapes")

local create_launcher       = require("src.taskbar.launcher")
local create_systray        = require("src.taskbar.systray")
local create_battery_widget = require("src.taskbar.battery")
local create_appmenu        = require("src.appmenu")
local control_center        = require("src.widgets.control_center")
local clock_widget          = require("src.widgets.clock")
local notification_center   = require("src.widgets.notify.center")
local create_tag_switcher   = require("src.taskbar.tag_switcher")
local create_tasklist       = require("src.taskbar.tasklist")

local unpack = require("src.agnostic.version.unpack")

local function color_border_widget(args)
    local layout = args.layout or wibox.layout.fixed.vertical

    local widgets = { unpack(args) }

    if #widgets > 1 then
        widgets.layout = layout

        widgets.fill_space = false

        widgets.spacing = args.spacing or 0
    else
        widgets = widgets[1]
    end

    local margins = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
    }

    gears.table.crush(margins, args.margins or {})

    return wibox.widget {
        {
            widgets,

            widget = wibox.container.margin,

            left = margins.left,
            right = margins.right,

            top = margins.top,
            bottom = margins.bottom
        },

        widget = wibox.container.background,
        shape = shapes.rounded_rect(100),

        bg = config.taskbar.widget_bg,

        shape_border_width = config.taskbar.border_width,
        shape_border_color = get_decoration_color(),
    }
end

local function create_taskbar()
    awful.screen.connect_for_each_screen(function(s)
        local is_primary = s == screen.primary

        create_tag_switcher(s)

        if is_primary then
            s.left_bar = awful.wibar {
                position = "left",
                screen = s,
                bg = config.taskbar.bg,
                width = config.taskbar.left
            }

            s.left_bar:setup {
                layout = wibox.layout.align.vertical,
                expand = "none",
                {
                    widget = wibox.container.margin,
                    left = config.taskbar.gap,
                    top = config.taskbar.gap,
                    create_tasklist(s),
                },
                notification_center.get_button(),
                {
                    widget = wibox.container.margin,
                    left = config.taskbar.gap,
                    bottom = config.taskbar.gap,
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = 3,

                        create_systray(),
                        create_launcher(),
                    }
                }
            }
        end

        s.top_bar = awful.wibar {
            position = "top",
            screen = s,
            bg = config.taskbar.bg,
            height = config.taskbar.top
        }

        s.layout_indicator = awful.widget.layoutbox(s)
        s.layout_indicator:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 2, function() layout_selector(true) end),
            awful.button({}, 4, function() awful.layout.inc(1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end)))

        s.top_bar:setup {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            {
                widget = wibox.container.margin,
                left = config.taskbar.gap,
                top = config.taskbar.gap,
                {
                    is_primary and system_status(),
                    is_primary and create_appmenu(),

                    layout = wibox.layout.fixed.horizontal,
                    spacing = 5
                }
            },
            {
                widget = wibox.container.margin,
                top = config.taskbar.gap,
                is_primary and color_border_widget {
                    margins = {
                        left = 10,
                        right = 10
                    },
                    clock_widget()
                }
            },
            {
                widget = wibox.container.margin,
                right = config.taskbar.gap,
                top = config.taskbar.gap,
                color_border_widget {
                    layout = wibox.layout.fixed.horizontal,
                    margins = {
                        left = 5,
                        right = 10
                    },
                    s.tag_switcher,
                    is_primary and create_battery_widget and create_battery_widget(),
                    --require("src.battery-widget") { adapter = "BAT0", ac = "AC" },
                    s.layout_indicator,
                    is_primary and control_center(),
                }
            },
        }
    end)
end

return create_taskbar
