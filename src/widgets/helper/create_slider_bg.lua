local gcolor = require("gears.color")
local config = require("config")

-- I don't need no stinking handle!
---@param w table slider widget to create handle for
local function create_slider_bg(w)
    local value = w.value

    local maximum = w.maximum
    local minimum = w.minimum

    local percent_pos = (value - minimum) / (maximum - minimum)

    return gcolor {
        type = "linear",

        from = { 0, 1 },
        to   = { w.width, 1 },

        stops = {
            { 0, config.button.hover },
            { percent_pos, config.button.hover },
            { percent_pos, config.button.normal },
            { 1, config.button.normal },
        }
    }
end

return create_slider_bg