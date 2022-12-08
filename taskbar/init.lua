local awful                 = require("awful")
local wibox                 = require("wibox")
local config                = require("config")
local gears                 = require("gears")
local create_battery_widget = require("awesome-battery_widget")
local config_dir            = gears.filesystem.get_configuration_dir()
local system_status         = require("widgets.system_status")
local layout_selector       = require("widgets.layout_selector")

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

local unpack = require("agnostic.version.unpack")

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
            awful.button({}, 2, function() layout_selector(true) end),
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

        local percentage = wibox.widget {
            widget = wibox.widget.textbox,
            text = "??",
            id = "textbox"
        }

        local battery_widget = create_battery_widget {
            screen = s,
            use_display_device = true,
            --widget_template = wibox.widget.imagebox
            widget_template = {
                layout = wibox.layout.stack,
                {
                    layout = wibox.container.margin,
                    left = 3,
                    top = 3,
                    bottom = 3,
                    right = 7,
                    {
                        layout = wibox.container.place,
                        percentage
                    }
                },
                {
                    widget = wibox.widget.imagebox,
                    image = config_dir .. "icon/battery/battery-dead-outline.svg"
                },
            }
        }

        battery_widget:connect_signal('upower::update', function(widget, device)
            --[[
            if device.percentage > 75 then
                widget.image = config_dir .. "icon/battery/battery-full-outline.svg"                
            elseif device.percentage > 50 then
                widget.image = config_dir .. "icon/battery/battery-half-outline.svg"
            else
                widget.image = config_dir .. "icon/battery/battery-dead-outline.svg"
            end
            ]]

            percentage.text = string.format('%3d', device.percentage)

            -- widget.text = string.format('%3d', device.percentage) .. '%'
        end)

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
                    battery_widget,
                    --require("battery-widget") { adapter = "BAT0", ac = "AC" },
                    s.layout_indicator,
                    control_center(),
                }
            },
        }
    end)
end

return create_taskbar
