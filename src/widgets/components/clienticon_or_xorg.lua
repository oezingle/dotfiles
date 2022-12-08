local base           = require("wibox.widget.base")
local gtable         = require("gears.table")
local awful          = require("awful")
local arbitrary_icon = require("src.widgets.components.arbitrary_icon")
local Class          = require("src.util.Class")

local clienticon_or_xorg = {}

local function clienticon_or_xorg_set_correct_internal_widget(self)
    if not self._private.client then
        self._private.widget = arbitrary_icon("dialog-question")
    else
        if self._private.client.icon then
            self._private.widget = awful.widget.clienticon(self._private.client)
        else
            self._private.widget = arbitrary_icon("xorg")
        end
    end
end

function clienticon_or_xorg:fit(context, width, height)
    return base.fit_widget(self, context, self._private.widget, width, height)
end

function clienticon_or_xorg:layout(_, width, height)
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
end

function clienticon_or_xorg:set_client(c)
    self._private.client = c

    clienticon_or_xorg_set_correct_internal_widget(self)
end

function clienticon_or_xorg:init(c)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, clienticon_or_xorg, true)

    -- set icon to dialog-question
    clienticon_or_xorg_set_correct_internal_widget(ret)

    if c then
        ret.client = c
    end

    return ret
end

return Class(clienticon_or_xorg)
