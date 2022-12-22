local config = require("config")

local ensure_client_decoration = require("src.client.colorize")

-- set width of a border based on floating/tiled state
local function mod_width(c)
    if c.fullscreen then
        c.border_width = 0
    elseif c.floating then
        c.border_width = config.border.floating_width
    else
        c.border_width = config.border.tiled_width
    end
end

client.connect_signal("unfocus", function(c)
    ensure_client_decoration(c)

    c.border_color = c.decoration_color
end)

for _, signal in ipairs({ 
    "manage",
    "property::geometry",
    "property::floating"
}) do
    client.connect_signal(signal, function(c)
        ensure_client_decoration(c)

        c.border_color = c.decoration_color

        mod_width(c)
    end)
end