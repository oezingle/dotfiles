local base   = require("wibox.widget.base")
local gtable = require("gears.table")
local Class  = require("src.util.Class")

local get_preferred_size = require("src.widgets.helper.get_preferred_size")

local pannable_layout = {}

local pack = require("src.agnostic.version.pack")

function pannable_layout:fit(_, width, height)
    return width, height
end

function pannable_layout:layout(_, _, _)
    local x, y = self._private.position[1], self._private.position[2]

    -- Tell the child it has infinite space
    local width, height = get_preferred_size(self._private.widget)

    return { base.place_widget_at(self._private.widget, x, y, width, height) }
end

function pannable_layout:before_draw_children(_, cr, width, height)
    cr:rectangle(0, 0, width, height)
    cr:clip()
end

function pannable_layout:get_children()
    return { self._private.widget }
end

function pannable_layout:set_child(value)
    assert(value, "Pannable layout requires a child")

    local widget = base.make_widget_from_value(value)
    base.check_widget(widget)
    self._private.widget = widget

    local position = value.position or { 0, 0 }
    self._private.position = position
end

function pannable_layout:set_children(...)
    local children = pack(...)[1]
    
    assert(#children == 1, "Pannable layout may only have 1 child")

    local value = children[1]

    return self:set_child(value)
end

function pannable_layout:move(point)
    assert(point)

    local x, y = point.x or point[1], point.y or point[2]

    self._private.position = { x, y }

    self:emit_signal("widget::layout_changed")
end

function pannable_layout:new()

    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, pannable_layout, true)

    ret._private.widget = nil
    ret._private.position = {0, 0}

    return ret
end

return Class(pannable_layout)