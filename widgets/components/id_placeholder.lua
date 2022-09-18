local wibox = require("wibox")

local function id_placeholder(id)
    return {
        nil,
        id = id,
        widget = wibox.container.margin,
        margins = 0
    }
end

return id_placeholder
