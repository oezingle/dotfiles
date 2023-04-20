local wibox    = require("wibox")
local base     = require("wibox.widget.base")
local gtable   = require("gears.table")
local gsurface = require("gears.surface")
local Class    = require("src.util.Class")
local wal      = require("src.util.wal")
local fs       = require("src.util.fs")

local wal_svg  = {}

function wal_svg:fit(context, width, height)
    return base.fit_widget(self, context, self._private.widget, width, height)
end

function wal_svg:layout(_, width, height)
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
end

function wal_svg:_reload()
    local path = self._private.path

    if not path then
        return
    end

    local scheme = wal()

    if not scheme then
        return
    end

    local content = fs.read(path) or ""

    content = content:gsub(self._private.replace, scheme.special.foreground)

    fs.write(fs.directories.cache .. "wal_svg.svg", content)

    self._private.widget.image = gsurface.load_uncached(fs.directories.cache .. "wal_svg.svg")

    -- self:emit_signal("widget::redraw_needed")
end

---@param path string
function wal_svg:set_image(path)
    self._private.path = path

    self._private.widget = wibox.widget {
        image = path,
        widget = wibox.widget.imagebox
    }

    self:_reload()
end

--- Set the string that is replaced with the pywal scheme
---@param replace string
function wal_svg:set_replace(replace)
    self._private.replace = replace

    self:_reload()
end

function wal_svg:init(image)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, wal_svg, true)

    ret._private.replace = "currentColor"

    if image then
        ret.image = image
    end

    wal.on_change(function()
        ret:_reload()
    end)

    return ret
end

return Class(wal_svg)
