local base                   = require("wibox.widget.base")
local gsurface               = require("gears.surface")
local gtable                 = require("gears.table")
local gshape                 = require("gears.shape")
local wallpaper_subscription = require("src.util.wallpaper.subscription")

local Class                  = require("src.util.Class")


---@class Widget.Wallpaper
---@field _private { radius: number }
---@field path string
---@field subscription Wallpaper.Subscription.Class
local wallpaper_widget = {}

function wallpaper_widget:fit(_, width, height)
    return width, height
end

function wallpaper_widget:draw(_, cr, width, height)
    self.subscription:set_dimensions(width, height)

    self.subscription:generate()

    local s = gsurface(self.path)

    -- TODO steal scaling stuff from src/widgets/element/client_preview.lua

    gshape.rounded_rect(cr, width, height, self._private.radius)

    cr:clip()
    cr:set_source_surface(s)
    cr:paint()
end

---@param identifier string|integer|nil
function wallpaper_widget:set_identifier(identifier)
    self.subscription:set_identifier(identifier)
end

---@param blur boolean
function wallpaper_widget:set_blur(blur)
    self.subscription:set_blur(blur)
end

function wallpaper_widget:set_radius(radius)
    self._private.radius = radius
end

function wallpaper_widget:init(identifier)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, wallpaper_widget, true)

    ret.subscription = wallpaper_subscription()
        :init(function (path)
            ret.path = path
        end)
        :disable_auto_generate()

    ret:set_identifier(identifier)

    ret:set_radius(0)

    return ret
end

return Class(wallpaper_widget)
