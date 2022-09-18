local Class = require("util.Class")

local gears    = require("gears")
local gtable   = gears.table
local gshape   = gears.shape
local gsurface = gears.surface
local base     = require("wibox.widget.base")

-- honestly some of the cleanest code I've ever written. complex, works, has no todos

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local IconTheme = Gtk.IconTheme

local icon_theme = IconTheme.get_default()

local arbitrary_icon = {}

-- https://github.com/awesomeWM/awesome/blob/master/lib/awful/widget/clienticon.lua
-- (modified)
local function find_best_size(icon_theme, icon_name, width, height)
    local sizes = icon_theme:get_icon_sizes(icon_name)

    height = height or width

    local best, best_size
    for k, size in ipairs(sizes) do
        if size == -1 then
            -- the best size is any size because this icon is scalable
            return math.min(width, height)
        end

        if not best then
            best, best_size = k, size
        else
            local best_too_small = best_size < width or best_size < height
            local best_too_large = best_size > width or best_size > height
            local better_because_bigger = best_too_small and size > best_size and size > best_size
            local better_because_smaller = best_too_large and size < best_size and size < best_size
                and size >= width and size >= height
            if better_because_bigger or better_because_smaller then
                best, best_size = k, size
            end
        end
    end
    return best_size
end

function arbitrary_icon:fit(context, width, height)
    local best_size = find_best_size(icon_theme, self.icon_name, width, height)

    return best_size, best_size
end

function arbitrary_icon:draw(context, cr, width, height)
    local icon_name = self.icon_name

    local best_size = find_best_size(icon_theme, icon_name, width, height)

    local icon = icon_theme:load_icon(icon_name, best_size, {})

    local surface_userdata = awesome.pixbuf_to_surface(icon._native)

    -- gears.surface() takes userdata. nice.
    local surface = gsurface(surface_userdata)

    local display_size = math.min(width, height)

    -- Center the icon
    local dx, dy = (width - display_size) / 2, (height - display_size) / 2

    cr:translate(dx, dy)

    -- add a rounded rect with radius 0 to the cairo surface
    -- in order to have a drawing surface
    gshape.rounded_rect(cr, display_size, display_size)

    cr:clip()

    cr:set_source_surface(surface)
    cr:paint()
end

function arbitrary_icon:new(name)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, arbitrary_icon, true)

    ret.icon_name = name

    return ret
end

return Class(arbitrary_icon)
