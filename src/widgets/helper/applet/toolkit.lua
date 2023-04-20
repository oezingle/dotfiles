local no_scroll       = require("src.widgets.helper.function.no_scroll")
local wibox           = require("wibox")
local get_font        = require("src.util.get_font")
local shapes          = require("src.util.shapes")
local config          = require("config")

local toolkit         = {}

---@enum ToolkitFontSize
toolkit.font_size     = {
    TITLE    = 18,
    SUBTITLE = 14,
    BODY     = 12,
    TINY     = 10
}

---@alias FontSize ToolkitFontSize|number

--- Create a button
---@param widget table|any
---@param callback function?
---@param style { hover: Color?, normal: Color?, radius: number? }?
---@return table widget
toolkit.widget_button = function(widget, callback, style)
    style = style or {}

    style.normal = style.normal or config.button.normal
    style.hover = style.hover or config.button.hover

    style.radius = style.radius or 5

    local widget = wibox.widget {
        {
            widget,
            layout = wibox.container.place
        },

        bg = style.normal,

        shape = shapes.rounded_rect(style.radius),

        widget = wibox.container.background
    }

    widget:connect_signal("mouse::enter", function(self)
        self.bg = style.hover
    end)

    widget:connect_signal("mouse::leave", function(self)
        self.bg = style.normal
    end)

    if callback then
        widget:connect_signal("button::press", no_scroll(callback))
    end

    return widget
end

--- Create a button
---@param content string
---@param callback function?
---@param style { hover: Color?, normal: Color?, radius: number? }?
---@return table widget
toolkit.button        = function(content, callback, style)
    return toolkit.widget_button(
        {
            widget = wibox.widget.textbox,
            font = get_font(toolkit.font_size.BODY),
            text = content,
            id = "button-text"
        },
        callback,
        style
    )
end

---@param text string
---@param font_size FontSize?
---@param id string?
function toolkit.text(text, font_size, id)
    font_size = font_size or toolkit.font_size.BODY

    return {
        widget = wibox.widget.textbox,
        font   = get_font(font_size),
        text   = text,
        id     = id
    }
end

---@param text string
---@param id string?
function toolkit.title(text, id)
    return toolkit.text(text, toolkit.font_size.TITLE, id)
end

---@param text string
---@param id string?
function toolkit.subtitle(text, id)
    return toolkit.text(text, toolkit.font_size.SUBTITLE, id)
end

---@param text string
---@param id string?
function toolkit.body(text, id)
    return toolkit.text(text, toolkit.font_size.BODY, id)
end

---@param text string
---@param id string?
function toolkit.tiny(text, id)
    return toolkit.text(text, toolkit.font_size.TINY, id)
end

---@param id string
---@param font_size FontSize? default 12
function toolkit.id_text(id, font_size)
    font_size = font_size or toolkit.font_size.BODY

    return {
        widget = wibox.widget.textbox,
        font = get_font(font_size),
        id = id,
        text = "[Placeholder]"
    }
end

return toolkit
