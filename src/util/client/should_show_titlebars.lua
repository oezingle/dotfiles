local client_or_tag_floating = require("src.util.client.client_or_tag_floating")

---@param c Client
---@return boolean
local function should_show_titlebars(c)
    -- stupidest fix ever: client.request::titlebars is only called for windows that request titlebars, 
    -- and is never explicitly called, so I can just set boolean c.has_titlebar

    return (not c.requests_no_titlebar) and c.has_titlebar and client_or_tag_floating(c)
end

return should_show_titlebars
    