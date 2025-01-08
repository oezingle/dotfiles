--[[
    File: pannable.lua
    Author: Zingle Zingle
    Description:
        Layout that contains a single child, displaying only the portion visible to its x/y coordinates.
]]

local base   = require("wibox.widget.base")
local gtable = require("gears.table")


local max = math.max

---@class Zingle.Awesome.Mod.Pannable.Private
---@field position { [1]: integer, [2]: integer }
---@field max_viewport_size { [1]: integer, [2]: integer }
---@field widget Awesome.Wibox.Widget
---@field constrain "x" | "y" ?

---@class Zingle.Awesome.Mod.Pannable : Awesome.Wibox.Widget
---@field _private Zingle.Awesome.Mod.Pannable.Private
local pannable = {}

local pack = require("src.agnostic.version.pack")

function pannable:fit(_, width, height)
    return width, height
end

-- TODO clamp position?

function pannable:layout(context, w, h)
    local x, y = table.unpack(self._private.position)

    -- Tell the child it has infinite space unless constrained
    local constrain = self:get_constrain()
    local fit_w = constrain == "x" and w or -1
    local fit_h = constrain == "y" and h or -1

    local width, height = base.fit_widget(self, context, self._private.widget, fit_w, fit_h)

    local vw, vh = table.unpack(self._private.max_viewport_size)
    self._private.max_viewport_size = { max(vw, width), max(vh, height) }

    return { base.place_widget_at(self._private.widget, x, y, width, height) }
end

function pannable:before_draw_children(_, cr, width, height)
    cr:rectangle(0, 0, width, height)
    cr:clip()
end

function pannable:get_children()
    return { self._private.widget }
end

function pannable:set_child(value)
    assert(value, "Pannable layout requires a child")

    local widget = base.make_widget_from_value(value)
    base.check_widget(widget)
    self._private.widget = widget

    local position = value.position or { 0, 0 }
    self._private.position = position

    self:emit_signal("widget::redraw_needed")
end

function pannable:set_children(...)
    local children = pack(...)[1]

    if #children == 0 then
        return
    end

    assert(#children == 1, string.format("Pannable layout may only have 1 child, got %d", #children))

    local value = children[1]

    return self:set_child(value)
end

function pannable:move(point)
    assert(point)

    local x, y = point.x or point[1] or 0, point.y or point[2] or 0

    self._private.position = { x, y }

    self:emit_signal("widget::layout_changed")
end

---@param direction "x" | "y" | "width" | "height" | "nil"
function pannable:set_constrain(direction)
    assert(
        direction == "x" or
        direction == "y" or
        direction == "width" or
        direction == "height" or
        direction == nil,
        "Pannable constrain direction must be x/width or y/height"
    )

    if direction == "width" then
        direction = "x"
    elseif direction == "height" then
        direction = "y"
    end

    self._private.constrain = direction --[[ @as "x" | "y" ? ]]
end

---@return "x" | "y" ?
function pannable:get_constrain()
    return self._private.constrain
end

function pannable:init()
    self = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(self, pannable, true)

    self._private.widget = nil
    self._private.position = { 0, 0 }

    self._private.max_viewport_size = { 0, 0 }

    return self
end

return setmetatable(pannable, {
    __call = function(t, ...)
        return t:init(...)
    end
})
