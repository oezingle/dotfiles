local awful = require("awful")

---@param c Client
---@return boolean
local function client_or_tag_floating(c)
    if c.maximized then
        return false
    end

    if c.floating then
        return true
    end

    local tag_floating = false
    if c.first_tag then
        local tag_layout_name = awful.layout.getname(c.first_tag.layout)
        tag_floating = tag_layout_name == "floating"
    end

    return tag_floating
end

return client_or_tag_floating