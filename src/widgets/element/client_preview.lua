-- https://www.reddit.com/r/awesomewm/comments/akiqz2/any_way_to_get_a_image_preview_of_a_running_window/
-- with patched :fit() function

local wibox = require("wibox")
local gsurface = require("gears.surface")
local gshape = require("gears.shape")

local client_true_geometry = require("src.util.client.true_geometry")

local module = {}

local function fit(self, context, width, height)
    local c = self._private.client[1]
    local geo = client_true_geometry(c)
    local scale = math.min(width / geo.width, height / geo.height)
    return geo.width * scale, geo.height * scale
end

local function set_client(self, c)
    self._private.client[1] = c
    self:emit_signal("widget::redraw_needed")
end

local function draw(self, content, cr, width, height)
    local c = self._private.client[1]
    local s, geo = gsurface(c.content), client_true_geometry(c)
    local scale = math.min(width / geo.width, height / geo.height)
    local w, h = geo.width * scale, geo.height * scale

    local dx, dy = (width - w) / 2, (height - h) / 2
    cr:translate(dx, dy)
    gshape.rounded_rect(cr, w, h)
    cr:clip()
    cr:scale(scale, scale)
    cr:set_source_surface(s)
    cr:paint()
end

local function new(c)
    local ret = wibox.widget.base.make_widget(nil, nil, {
        enable_properties = true,
    })

    rawset(ret, "fit", fit)
    rawset(ret, "draw", draw)
    rawset(ret, "set_client", set_client)

    ret._private.client = setmetatable({ c }, { __mode = "v" })
    return ret
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
