local beautiful = require("beautiful")
local gears = require("gears")

--- A rounded rectangle
---@param radius number?
---@return function shape the shape function for a drawable
local function rounded_rect(radius)
    radius = radius or beautiful.border_radius

    return function(cx, w, h)
        return gears.shape.rounded_rect(cx, w, h, radius)
    end
end

--- A rounded rectangle
---@param radius number?
---@param tl boolean?
---@param tr boolean?
---@param bl boolean?
---@param br boolean?
---@return function shape the shape function for a drawable
local function partially_rounded_rect(radius, tl, tr, bl, br)
    radius = radius or beautiful.border_radius

    tl = tl or false
    tr = tr or false
    bl = bl or false
    br = br or false

    return function(cx, w, h)
        return gears.shape.partially_rounded_rect(cx, w, h, tl, tr, bl, br, radius)
    end
end

return {
    rounded_rect = rounded_rect,
    partially_rounded_rect = partially_rounded_rect
}
