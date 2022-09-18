-- TODO refactor to util.applet? widget.helper?

---@module 'util.Class'
local Class = require("util.Class")
local exitable_dialog = require("widgets.util.exitable_dialog")
local check_dependencies = require("util.check_dependencies")
local no_scroll          = require("widgets.helper.no_scroll")

local awful = require("awful")

local applet = {}

applet.toolkit = {}

-- toolkit dependencies
local wibox    = require("wibox")
local get_font = require("util.get_font")
local shapes   = require("util.shapes")
local config   = require("config")

applet.toolkit.button = function(content, callback, style)
    style = style or {}

    style.normal = style.normal or config.button.normal
    style.hover = style.hover or config.button.hover

    style.radius = style.radius or 5

    local widget = wibox.widget {
        {
            {
                widget = wibox.widget.textbox,
                font = get_font(12),
                text = content,

                id = "button-text"
            },
            layout = wibox.container.place
        },

        bg = style.normal,

        shape = shapes.rounded_rect(style.radius),

        widget = wibox.container.background
    }

    widget:connect_signal("mouse::enter", function(self)
        self.bg = style.hover
    end)

    widget:connect_signal("mouse::leave", function(self)
        self.bg = style.normal
    end)

    if callback then
        widget:connect_signal("button::press", no_scroll(callback))
    end

    return widget
end


function applet:new(widget, dependencies)
    dependencies = dependencies or {}

    self:set_dependencies(dependencies)

    self.widget = widget

    return self
end

function applet:set_dependencies(deps)
    self.dependencies = {}
end

function applet:on_close(fn)
    self._on_close = fn
end

function applet:create_internal_widget()
    self.popup = exitable_dialog {
        widget = self.widget,

        on_close = self._on_close
    }

    self.bindings.show = function()
        self.popup.visible = true
    end

    self.bindings.hide = function()
        self.popup.visible = false

        if self._on_close then
            self._on_close()
        end
    end

    self.bindings.toggle = function()
        if self.popup.visible then
            self.bindings.hide()
        else
            self.bindings.show()
        end
    end
end

function applet:create_bindings()
    if not self.bindings then
        self.bindings = {
            show = function() end,

            hide = function() end,

            toggle = function() end
        }

        check_dependencies(self.dependencies, function ()
            self:create_internal_widget()
        end)
    end
end

function applet:add_binding(name, fn)
    self:create_bindings()

    self.bindings[name] = fn
end

function applet:create()
    self:create_bindings()

    return self.bindings
end

return Class(applet)
