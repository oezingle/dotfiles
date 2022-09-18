local config = require("config")

local function get_font(size)
    return config.font.." "..tostring(size)
end

return get_font