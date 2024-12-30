local base = require("wibox.widget.base")
local gtable = require("gears.table")

---@diagnostic disable-next-line:deprecated
local unpack = unpack or table.unpack
local pack = table.pack or function(...) return { ... } end
local floor = math.floor
local max = math.max
local pairs = pairs
local ipairs = ipairs
local assert = assert

--[[
    File: flexbox.lua
    Auther: Zingle Zingle
    Description: 
        bidirectional AwesomeWM flexbox widget similar to CSS flexbox. has
        justify (start, end, center, between, around, even), align (start, end,
        center, stretch), and gap.
]]

---@param value number
---@return integer
local function round(value)
    return floor(value + 0.5)
end

--- start:      push all elements to the start
--- end:        push all elements to the end
--- center:     center all elements
--- between:    elements are equally as far from each other
--- even:       elements are equally far from each other and the walls
--- around:     every element has a personal bubble of equivalent size
---@alias Zingle.Awesome.Mod.Flexbox.Justify "start" | "end" | "center" | "between" | "around" | "even"

---@alias Zingle.Awesome.Mod.Flexbox.Align "start" | "end" | "center" | "stretch"


---@class Zingle.Awesome.Mod.Flexbox.Private
---@field widgets Awesome.Wibox.Widget[]
---@field direction "vertical" | "horizontal"
---@field justify Zingle.Awesome.Mod.Flexbox.Justify
---@field align Zingle.Awesome.Mod.Flexbox.Align
---@field gap number

---@class Zingle.Awesome.Mod.Flexbox
---@field _private Zingle.Awesome.Mod.Flexbox.Private
---
---@field fit fun(self: self, context: table, width: integer, height: integer): integer, integer
---@field layout fun(self: self, context: table, width: integer, height: integer): table
---
---@field emit_signal fun(self: self, signal: string | "widget::layout_changed", ...: any)
local flexbox = {}

function flexbox:fit(context, width, height)
    -- assumptions: expansion uses all available space and no more

    -- case where width, height = nil, nil exists according to https://github.com/awesomeWM/awesome/blob/master/lib/wibox/layout/fixed.lua
    if #self._private.widgets == 0 then
        return 0, 0
    end

    local is_horizontal = self:get_direction() == "horizontal"

    local max_length = 0

    for _, widget in pairs(self._private.widgets) do
        local w, h = base.fit_widget(self, context, widget, width, height)

        if is_horizontal then
            max_length = max(max_length, h)
        else
            max_length = max(max_length, w)
        end
    end

    if is_horizontal then
        return width, max_length
    else
        return max_length, height
    end
end

--- justified space fraction
---@protected
---@param position "before" | "between" | "after" The insert position of the given spacing. before widgets, between 2 widgets, or after widgets.
---@param child_count integer
function flexbox:_j_spacefrac(position, child_count)
    -- see note below justify table for information re: math_max here
    local n = max(child_count, 1)

    local mode = self:get_justify()

    local mode_index = ({
        ["start"] = 1,
        ["end"] = 2,
        ["center"] = 3,
        ["between"] = 4,
        ["around"] = 5,
        ["even"] = 6
    })[mode]

    local position_index = ({
        ["before"] = 1,
        ["between"] = 2,
        ["after"] = 3
    })[position]

    assert(mode_index and position_index, "invalid justify mode or position")

    --[[
    justify table
            before      between     after
    start    0           0           1
    end      1           0           0
    center   1/2         0           1/2
    between  0           1/(n-1)     0
    around   1/2n        1/n         1/2n
    even     1/(n+1)     1/(n+1)     1/(n+1)

    failure cases:
        between, n = 1 -> start (never occurs - only one widget, therefore no between pos. )
        around, n = 0 -> center (constrain n >= 1 fixes)
        even, n = -1 -> center (constrain n >= 1 fixes)
    ]]
    local justify_table = {
        -- Nils just make auto-format play nice :)
        -- start
        { 0,           0,           1,           nil },
        -- end
        { 1,           0,           0,           nil },
        -- center
        { 1 / 2,       0,           1 / 2,       nil },
        -- between
        { 0,           1 / (n - 1), 0,           nil },
        -- around
        { 1 / (2 * n), 1 / n,       1 / (2 * n), nil },
        -- even
        { 1 / (n + 1), 1 / (n + 1), 1 / (n + 1), nil }
    }

    return justify_table[mode_index][position_index]
end

--- Coordinate helper. retrieve either x or y
---@protected
---@param x integer
---@param y integer
---@param is_horizontal boolean
---@return integer
function flexbox:_coord_select(x, y, is_horizontal)
    return is_horizontal and x or y
end

--- Coordinate helper. Set either x or y to ths value, returning both
---@protected
---@param x integer
---@param y integer
---@param new integer
---@param is_horizontal boolean
---@return integer, integer
function flexbox:_coord_set(x, y, new, is_horizontal)
    if is_horizontal then
        return new, y
    else
        return x, new
    end
end

function flexbox:layout(context, width, height)
    local is_horizontal = self:get_direction() == "horizontal"
    -- TODO consider max_widget_size (ie, forced_width/forced_height) a la
    -- https://github.com/awesomeWM/awesome/blob/master/lib/wibox/layout/flex.lua

    -- calculate expansion

    local grow_total = 0

    -- length of non-expanded children, starting with the space taken by gap.
    local static_length = max(0, #self._private.widgets - 1) * self:get_gap()

    -- calculate space taken by non-expanded widgets & grow ownership
    -- pairs is ok here because marginally faster and calculations can be done out-of-order
    for _, widget in pairs(self._private.widgets) do
        local grow = widget.flex_grow or 0

        -- non-growing widgets are guaranteed their minimal space
        if grow == 0 then
            -- docs claim that fit_widget caches: https://awesomewm.org/doc/api/classes/wibox.widget.base.html#wibox.widget.base.fit_widget
            local w, h = base.fit_widget(self, context, widget, width, height)

            static_length = static_length + self:_coord_select(w, h, is_horizontal)
        else
            grow_total = grow_total + grow
        end
    end

    -- length of resizable content
    local dynamic_length = self:_coord_select(width, height, is_horizontal) - static_length

    local ret = {}

    -- either x or y (depending on direction) position value.
    local insert_pos = 0

    -- insert widgets with spacing
    do
        -- there's essentially two "modes" to flexbox: expand either children or
        -- spacing. In order to determine which we are within, we can just check if
        -- grow_total is nonzero
        local is_justify = grow_total == 0

        local n = #self._private.widgets

        -- children are spaced around to fill area depending on justify mode
        if is_justify then
            local skip_space = round(self:_j_spacefrac("before", n) * dynamic_length)
            insert_pos = insert_pos + skip_space
        end

        for _, widget in ipairs(self._private.widgets) do
            local grow = widget.flex_grow or 0

            -- always query fit because, h in horizontal mode is required and w in vertical.
            local w, h = base.fit_widget(self, context, widget, width, height)

            if grow ~= 0 then
                -- find new length of grow edge. + 0.5 for idealized rounding.
                local new_length = round((grow / grow_total) * dynamic_length)

                w, h = self:_coord_set(w, h, new_length, is_horizontal)

                if self:get_align() == "stretch" then
                    -- set inverse coordinate to 100% of available. save operations by switching arguments around
                    local container = self:_coord_select(height, width, is_horizontal)
                    h, w = self:_coord_set(h, w, container, is_horizontal)
                end
            end

            local initial_pos = 0
            if self:get_align() == "end" then
                initial_pos = self:_coord_select(height - h, width - w, is_horizontal)
            elseif self:get_align() == "center" then
                initial_pos = self:_coord_select(height - h, width - w, is_horizontal) / 2
            end

            local x, y = self:_coord_set(initial_pos, initial_pos, insert_pos, is_horizontal)

            table.insert(ret, base.place_widget_at(widget, x, y, w, h))

            insert_pos = insert_pos + self:_coord_select(w, h, is_horizontal) + self:get_gap()

            if is_justify then
                local skip_space = round(self:_j_spacefrac("between", n) * dynamic_length)
                insert_pos = insert_pos + skip_space
            end
        end
    end

    return ret
end

---@param justify Zingle.Awesome.Mod.Flexbox.Justify
function flexbox:set_justify(justify)
    assert(
        justify == "start" or
        justify == "end" or
        justify == "center" or
        justify == "between" or
        justify == "around" or
        justify == "even",
        string.format("Justify mode %q invalid. Must be one of: start, end, center, between, around, even",
            tostring(justify))
    )

    if self._private.justify ~= justify then
        self._private.justify = justify

        self:emit_signal("widget::layout_changed")
    end
end

function flexbox:get_justify()
    return self._private.justify
end

---@param align Zingle.Awesome.Mod.Flexbox.Align
function flexbox:set_align(align)
    assert(
        align == "start" or
        align == "end" or
        align == "center" or
        align == "stretch",
        string.format("Align mode %q invalid. Must be one of: start, end, center, stretch",
            tostring(align))
    )

    if self._private.align ~= align then
        self._private.align = align

        self:emit_signal("widget::layout_changed")
    end
end

function flexbox:get_align()
    return self._private.align
end

---@param gap number
function flexbox:set_gap(gap)
    assert(gap >= 0, "Gap may not be negative")

    if self._private.gap ~= gap then
        self._private.gap = gap

        self:emit_signal("widget::layout_changed")
    end
end

function flexbox:get_gap()
    return self._private.gap
end

---@param direction "vertical" | "horizontal"
function flexbox:set_direction(direction)
    assert(direction == "vertical" or direction == "horizontal",
        "Direction must be \"vertical\" or \"horizontal\"")

    self._private.direction = direction

    self:emit_signal("widget::layout_changed")
end

function flexbox:get_direction()
    return self._private.direction
end

function flexbox:get_children()
    return self._private.widgets
end

function flexbox:set_children(children)
    -- clone table just in case
    local clone = {}

    for i, child in ipairs(children) do
        clone[i] = base.make_widget_from_value(child)
    end

    self._private.widgets = clone

    self:emit_signal("widget::layout_changed")
end

---@param index integer
---@param child Awesome.Wibox.Widget | table
function flexbox:insert(index, child)
    -- TODO FIXME check_widget

    local widget = base.make_widget_from_value(child)

    table.insert(self._private.widgets, index, widget)

    -- self:emit_signal("widget::inserted", widget, #self._private.widgets)

    self:emit_signal("widget::layout_changed")
    self:emit_signal("widget::inserted", widget, #self._private.widgets)

    return true
end

---@param index integer
function flexbox:remove(index)
    table.remove(self._private.widgets, index)

    self:emit_signal("widget::layout_changed")
end

-- TODO FIXME horrible
function flexbox:add(...)
    local children = self:get_children()

    children = { unpack(children), ... }

    self:set_children(children)
end

function flexbox:reset()
    self._private.widgets = {}
    self._private.direction = "horizontal"
    self._private.justify = "start"
    self._private.align = "stretch"
    self._private.gap = 0

    self:emit_signal("widget::layout_changed")
end

function flexbox:init(...)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, flexbox, true)

    ret:reset()
    ret:set_children(pack(...))

    return ret
end

return setmetatable(flexbox, {
    __call = function(_, ...)
        return flexbox:init(...)
    end
})
