local config = require("config")

local function get_decoration_color () 
    local color_count = #config.decorations.colors

    -- use ceil because lua lists start at 1
    local number = math.ceil(math.random() * color_count)

    return config.decorations.colors[number]
end

return get_decoration_color