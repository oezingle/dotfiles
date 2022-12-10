
local awful = require("awful")
local wibox = require("wibox")
local no_scroll = require("src.widgets.helper.no_scroll")
local autoclose = require("src.widgets.helper.autoclose")

local gears = require("gears")
local gfs = gears.filesystem
local config_dir = gfs.get_configuration_dir()

local config = require("config")

local class = require("lib.30log")

local get_decoration_color = require("src.util.color.get_decoration_color")

local dropdown = class("Dropdown Widget")

function dropdown:init (args)    
    self.popup = awful.popup {
        widget = args.widget,

        --placement = args.placement or awful.placement.centered,
        shape = args.shape or gears.shape.rectangle,
        ontop = true,
        visible = false,

        bg = config.popup.bg,

        border_width = config.border.floating_width,
        border_color = config.popup.border or get_decoration_color(),

        hide_on_right_click = args.hide_on_right_click
    }

    autoclose(self.popup)

    self.popup:connect_signal("property::visible", function (p)
        if p.widget then
            p.widget.visible = p.visible

            p.widget:emit_signal("property::visible")
        end
    end)

    self.icon_closed = args.icon_closed or config_dir.."icon/arrow/caret-down-outline.svg"
    self.icon_open = args.icon_open or config_dir.."icon/arrow/caret-up-outline.svg"
    
    self.__index = self

    return self
end

function dropdown:get_button()
    local button = wibox.widget {
        image = self.icon_closed,
        widget = wibox.widget.imagebox
    }

    -- propogate visibility down so that a user-defined widget can detect being hidden
    -- I considered get_all_children and emitting to them, but a complex child widget would be SLOW
    button:connect_signal("button::press", no_scroll(function () 
        if self.popup.visible then            
            self.popup.visible = false
        else
            self.popup:move_next_to(mouse.current_widget_geometry)
        end

        button.image = (self.popup.visible and self.icon_open) or self.icon_closed
    end))

    return button
end

function dropdown:get_internal_popup()
    return self.popup
end

return dropdown
