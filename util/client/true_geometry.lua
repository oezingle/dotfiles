-- https://github.com/awesomeWM/awesome/issues/3675

local function true_geometry(c)
    local _, top_size = c:titlebar_top()
    local _, right_size = c:titlebar_right()
    local _, bottom_size = c:titlebar_bottom()
    local _, left_size = c:titlebar_left()

    local c_geo = c:geometry()

    local actual_geo = {
        x      = c_geo.x + left_size,
        y      = c_geo.y + top_size,
        width  = c_geo.width - right_size - left_size,
        height = c_geo.height - bottom_size - top_size,
    }

    return actual_geo
end

return true_geometry