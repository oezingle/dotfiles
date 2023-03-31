
local wibox = require("wibox")

---@alias WidgetTemplate table|Widget|(fun(): table)|(fun(): Widget)

--- Parse a table, wibox.widget, or function that
--- results in one of those two to a wibox.widget
---@param template WidgetTemplate
local function parse_widget_template(template)
    if type(template) == "function" then
        -- Call the function and parse the result
        return parse_widget_template(template())
    else
        -- This is a widget
        if template.is_widget then
            return template
        else
            return wibox.widget(template)
        end
    end
end

return parse_widget_template