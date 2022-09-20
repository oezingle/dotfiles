local config = require("config")

--- Get the interface font in a given size
---@param size number
---@return string
local function get_font(size)
    return config.font.." "..tostring(size)
end

return get_font