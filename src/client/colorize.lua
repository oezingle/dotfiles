
-- expose client
require("awful")

local get_decoration_color = require("src.util.color.get_decoration_color")

local function ensure_decoration_color (c)
    if not c.decoration_color then
        c.decoration_color = get_decoration_color()
    end
end

client.connect_signal("manage", function (c)
    ensure_decoration_color(c)
end)

return ensure_decoration_color