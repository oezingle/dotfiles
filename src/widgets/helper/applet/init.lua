-- TODO refactor to util.applet? widget.helper?

local class = require("lib.30log")
local exitable_dialog = require("src.widgets.util.exitable_dialog")
local check_dependencies = require("src.util.check_dependencies")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

local applet = class("Applet", {
    toolkit = require(folder_of_this_file .. "applet.toolkit")
})

function applet:init(widget, dependencies)
    dependencies = dependencies or {}

    self:set_dependencies(dependencies)

    self.widget = widget

    return self
end

function applet:set_dependencies(deps)
    self.dependencies = deps
end

function applet:on_close(fn)
    self._on_close = fn
end

function applet:on_open(fn)
    self._on_open = fn
end

function applet:create_internal_widget()
    self.popup = exitable_dialog {
        widget = self.widget,

        on_close = self._on_close
    }

    self.bindings.show = function()
        self.popup.visible = true

        if self._on_open then
            self._on_open()
        end
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

        check_dependencies(self.dependencies, function()
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

return applet