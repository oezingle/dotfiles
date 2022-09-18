local beautiful = require("beautiful")

-- Get the preferred height of a widget
-- https://github.com/awesomeWM/awesome/issues/611
local function get_preferred_size(widget, context, width, height)
    local context = context or 1

    if type(context) == "number" then
        context = { dpi = beautiful.xresources.get_dpi(context) }
    elseif not context.dpi then
        context.dpi = beautiful.xresources.get_dpi(1)
    end

    return widget:fit(context, width or 9999, height or 9999)
end

return get_preferred_size