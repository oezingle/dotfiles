local wibox       = require("wibox")
local gtable      = require("gears.table")
local base        = require("wibox.widget.base")
local format_date = require("src.util.date").format
local get_font    = require("src.util.get_font")
local Class       = require("src.util.Class")

local pack = require("src.agnostic.version.pack")

local datetime = {}

function datetime:update()
    self._private.widget.text = format_date(self.time)
end

function datetime:fit(context, width, height)
    return base.fit_widget(self, context, self._private.widget, width, height)
end

function datetime:layout(_, width, height)
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
end

function datetime:set_children(...)
    local args = pack(...)

    assert(#args == 1, "datetime may only have a single child")

    self._private.widget = args[1]
end

---@param time integer?
---@return table widget
function datetime:new(time)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, datetime, true)

    ret.time = time or os.time()

    ret._private.widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = get_font(12),
    }

    datetime.update(ret)

    return ret
end

--[[
setmetatable(datetime, { __call = function(_, ...)
    return datetime.new({}, ...)
end })

return datetime
]]

return Class(datetime)
