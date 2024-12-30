local gshape = require("gears.shape")

-- Cache closures to limit memory usage
local rounded_rect = {
    cache = {}
}

---@param radius number | nil
---@return Awesome.Gears.Shape | nil
function rounded_rect.get(radius)
    radius = radius or 0

    if not rounded_rect.cache[radius] then
        local shape = function(cr, width, height)
            gshape.rounded_rect(cr, width, height, radius)
        end

        rounded_rect.cache[radius] = shape
    end

    return rounded_rect.cache[radius]
end

return rounded_rect
