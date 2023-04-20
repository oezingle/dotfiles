local config = require("config")

-- Get the background (more like border) for a tag indicator
local function get_tag_bg(t)
    local bg = config.tag.empty

    if #t:clients() > 0 then
        bg = config.tag.occupied
    end

    if t.selected then
        bg = config.tag.focus
    end

    return bg
end

return get_tag_bg