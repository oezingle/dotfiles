-- A not half bad text input 'widget'

local wibox = require("wibox")
local awful = require("awful")
local config = require("config")
local shapes = require("src.util.shapes")

local Class = require("src.util.Class")

local textinput = {}

function textinput:init(args)
    args = args or {}

    self.text = ""
    self.cursor_pos = 1

    self:_create_widget(args)
    self:_create_keygrabber()

    self:_bind_listeners()

    return self
end

function textinput:_create_widget(args)
    local passed_args = {
        "align",
        "valign",
        "wrap",
        "ellipsize",
        "font",
        "forced_height",
        "forced_width",
        "opacity",
        "visible"
    }

    self.widget = wibox.widget {
        {
            {
                widget = wibox.widget.textbox,
                id = "textbox"
            },
            {
                {
                    -- Invisible textbox provides length for cursor
                    widget = wibox.widget.textbox,
                    opacity = 0.0,
                    id = "textbox"
                },
                {
                    widget = wibox.widget.textbox,
                    text = "|"
                },
                layout = wibox.layout.fixed.horizontal,
                spacing = 0,
            },
            layout = wibox.layout.stack,
        },
        {
            widget = wibox.widget.progressbar,

            id = "focus-indicator",

            max_value = 100,
            value = 0,

            color = config.progressbar.fg,
            background_color = config.progressbar.bg,

            shape = shapes.rounded_rect(),

            forced_width = args.forced_width,
            forced_height = 3
        },
        layout = wibox.layout.fixed.vertical,
    }

    self.textboxes = self.widget:get_children_by_id("textbox")

    -- pass allowed args to the widgets, if provided
    for _, child in ipairs(self.textboxes) do
        for _, key in ipairs(passed_args) do
            if args[key] ~= nil then
                child[key] = args[key]
            end
        end
    end

    self.textboxes[2].forced_width = nil

    self.focus_indicator = self.widget:get_children_by_id("focus-indicator")[1]

    self.validator = args.validator or nil
end

function textinput:_create_keygrabber()
    -- create a keygrabber for any key
    self.keygrabber = awful.keygrabber {
        auto_start = true,
        keypressed_callback = function(_, mod, key, command)
            if #key == 1 then
                local tmp_text = self.text

                -- Any single-length printable character is appended
                if self.cursor_pos == 1 then
                    tmp_text = tmp_text .. key
                else
                    tmp_text = tmp_text:sub(1, -self.cursor_pos) .. key .. tmp_text:sub(1 - self.cursor_pos)
                end

                -- allow validation
                if not self.validator or self.validator(tmp_text) then
                    self.text = tmp_text
                end
            elseif key == "BackSpace" then
                -- Remove last char
                if self.cursor_pos == 1 then
                    self.text = self.text:sub(1, -2)
                else
                    self.text = self.text:sub(1, -1 - self.cursor_pos) .. self.text:sub(1 - self.cursor_pos)
                end
                --elseif key == "Delete" then
                --    self.text = self.text:sub()
            elseif key == "Left" then
                self.cursor_pos = self.cursor_pos + 1

            elseif key == "Right" then
                self.cursor_pos = self.cursor_pos - 1

                if self.cursor_pos < 1 then
                    self.cursor_pos = 1
                end
            end

            -- Text length changes all the time, so check often
            if self.cursor_pos > #self.text + 1 then
                self.cursor_pos = #self.text + 1
            end

            self:text_update()
        end
    }
end

-- The text has changed!
function textinput:text_update()
    self.textboxes[1].text = self.text

    self.textboxes[2].text = self.text:sub(1, -self.cursor_pos)

    self.widget.value = self.text
end

function textinput:_bind_listeners()
    self.widget:connect_signal("mouse::enter", function()
        self.keygrabber:start()

        self.focus_indicator.value = 100
    end)

    self.widget:connect_signal("mouse::leave", function()
        self.keygrabber:stop()

        self.focus_indicator.value = 0
    end)
end

function textinput:get_widget()
    return self.widget
end

function textinput:set_text(new_text)
    self.text = new_text

    self:text_update()
end

function textinput:get_text()
    if self.validator then
        if self.validator(self.text) then
            return self.text
        end
    else
        return self.text
    end
end

return Class(textinput)
