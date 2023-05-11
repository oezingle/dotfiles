local base          = require("wibox.widget.base")
local gsurface      = require("gears.surface")
local gtable        = require("gears.table")
local gshape        = require("gears.shape")
local get_wallpaper = require("src.util.wallpaper_old.get_wallpaper")
local wallpaper     = require("src.util.wallpaper_old")

local Class = require("src.util.Class")

local wallpaper_widget = {}

function wallpaper_widget:fit(context, width, height)
    return width, height
end

function wallpaper_widget:draw(content, cr, width, height)
    local s = gsurface(get_wallpaper(width, height, false, self._private.identifier))

    gshape.rounded_rect(cr, width, height, self._private.radius)

    cr:clip()
    cr:set_source_surface(s)
    cr:paint()
end

function wallpaper_widget:set_identifier(identifier)
    self._private.identifier = identifier
end

function wallpaper_widget:set_radius(radius)
    self._private.radius = radius
end

function wallpaper_widget:init(identifier)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, wallpaper_widget, true)

    if identifier then
        ret:set_identifier(identifier)
    else
        ret:set_identifier(wallpaper.get_current_identifier())
    end

    ret:set_radius(0)

    return ret
end

return Class(wallpaper_widget)
