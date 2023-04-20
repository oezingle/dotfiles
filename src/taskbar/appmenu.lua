local config         = require("config")
local wal            = require("src.util.wal")
local shapes         = require("src.util.shapes")

local appmenu_widget = require("src.appmenu.widget")
local get_font       = require("src.util.get_font")

local wibox          = require("wibox")

local function create_appmenu()
    if not config.gimmicks.global_menu then
        return
    end

    return appmenu_widget({
        button_template = {
            horizontal = function()
                local widget = wibox.widget {
                    layout = wibox.container.background,
                    {
                        layout = wibox.container.margin,
                        left = 3,
                        right = 3,
                        top = 2,
                        bottom = 2,
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "inside",
                            {
                                widget = wibox.widget.textbox,
                                id = "text-role",
                                font = get_font(13)
                            },
                            nil,
                            {
                                widget = wibox.widget.textbox,
                                id = "icon-role",
                                font = get_font(13)
                            }
                        }
                    }
                }

                wal.on_change(function(scheme)
                    widget.fg = scheme.special.foreground
                end)

                return widget
            end,
            vertical = function()
                -- TODO remove icon widget if not needed
                local widget = wibox.widget {
                    layout = wibox.container.background,
                    {
                        layout = wibox.container.margin,
                        left = 15,
                        right = 15,
                        top = 2,
                        bottom = 2,
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "inside",
                            {
                                widget = wibox.widget.imagebox,
                                id = "icon-role",
                                visible = false
                            },
                            {
                                widget = wibox.widget.textbox,
                                id = "text-role",
                                font = get_font(13)
                            },
                            {
                                widget = wibox.widget.textbox,
                                id = "shortcut-role",
                                font = get_font(13),
                                visible = false
                            }
                        }
                    }
                }

                -- Append extra space after the text if the menu item has a shortcut
                local shortcut = widget:get_children_by_id("shortcut-role")[1]

                shortcut:connect_signal("widget::redraw_needed", function(w)
                    w.visible = w.text ~= ""
                end)

                -- Append extra space after the text if the menu item has a shortcut
                local icon = widget:get_children_by_id("shortcut-role")[1]

                icon:connect_signal("widget::redraw_needed", function(w)                    
                    w.visible = w.image ~= ""
                end)

                wal.on_change(function(scheme)
                    widget.fg = scheme.special.foreground
                end)

                return widget
            end
        },
        -- TODO divider_template separator
        menu_template = {
            vertical = function()
                local widget = wibox.widget {
                    layout = wibox.container.background,
                    {
                        layout = wibox.container.margin,
                        margins = 5,
                        {
                            layout = wibox.layout.fixed.vertical,
                            {
                                -- forces the menu to be a certain width
                                widget = wibox.widget.textbox,
                                forced_width = 64
                            },
                            {
                                layout = wibox.layout.fixed.vertical,
                                spacing = 2,
                                id = "menu-role"
                            },
                        },
                    }
                }

                -- TODO better transparency fix
                wal.on_change(function(scheme)
                    widget.bg = scheme.special.background .. "66"
                end)

                return widget
            end
        },
        shortcut_symbols = {
            ['Control'] = '⌃',
            ['Shift'] = '⇧',
            ['Alt'] = '⌥',
            ['Super'] = '⌘',
            ['children'] = '▶',
        },
        popup_shape = shapes.rounded_rect()
    })
end

return create_appmenu
