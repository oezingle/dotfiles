local awful  = require("awful")
local wibox  = require("wibox")
local config = require("config")
local gears  = require("gears")
local system_status = require("widgets.system_status")

local get_decoration_color = require("util.color.get_decoration_color")
local shapes = require("util.shapes")

local create_launcher     = require("taskbar.launcher")
local create_systray      = require("taskbar.systray")
local create_appmenu      = require("appmenu")
local control_center      = require("widgets.control_center")
local clock_widget        = require("widgets.clock")
local notification_center = require("widgets.notify.center")
local create_tag_switcher = require("taskbar.tag_switcher")
local create_tasklist     = require("taskbar.tasklist")

local function color_border_widget(args)
    local layout = args.layout or wibox.layout.fixed.vertical

    local widgets = { table.unpack(args) }

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
        -- Set layouts per-tag
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

        create_tag_switcher(s)

        s.left_bar = awful.wibar {
            position = "left",
            screen = s,
            bg = config.taskbar.bg,
            width = config.taskbar.left
        }

        s.layout_indicator = awful.widget.layoutbox(s)
        s.layout_indicator:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end)))

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

        s.top_bar = awful.wibar {
            position = "top",
            screen = s,
            bg = config.taskbar.bg,
            height = config.taskbar.top
        }

        s.top_bar:setup {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            {
                widget = wibox.container.margin,
                left = config.taskbar.gap,
                top = config.taskbar.gap,
                {
                    system_status(),
                    create_appmenu(),

                    layout = wibox.layout.fixed.horizontal,
                    spacing = 5
                }
            },
            {
                widget = wibox.container.margin,
                top = config.taskbar.gap,
                color_border_widget {
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
                    require("battery-widget") { adapter = "BAT0", ac = "AC" },
                    s.layout_indicator,
                    control_center(),
                }
            },
        }
    end)
end

return create_taskbar