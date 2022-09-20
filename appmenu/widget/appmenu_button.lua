local gtable    = require("gears.table")
local gtimer    = require("gears.timer")
local wibox     = require("wibox")
local config    = require("config")
local no_scroll = require("widgets.helper.no_scroll")
local get_font  = require("util.get_font")

-- Format GTK-style (not always under GTK though) labels
---@param label string The label string - a <type>_menu_item.label
---@param is_keygrabbing boolean|nil If the keyboard shortcuts should be highlighed
---@return string formatted the formatted label
local function format_label(label, is_keygrabbing)
    is_keygrabbing = is_keygrabbing or false

    if not label then return "[Empty_Label]" end

    local tmp = label:gsub("_(%a)", is_keygrabbing and "<b>%1</b>" or "%1")

    return tmp
end

--- Create a button for the global menu
---@param state global_menu_state
---@param label string button label
---@param widget_args table|nil additional arguments for the widget
---@param get_menu fun(widget: table): (table|nil) | nil function that generates the child menu
---@param handle_click fun(widget: table, textbox: table)|nil what to do when the bad boy is clicked
---@return any widget, any text_widget
local function appmenu_button(state, label, widget_args, get_menu, handle_click)
    widget_args = widget_args or {}

    get_menu = get_menu or function() end

    local text = wibox.widget(gtable.crush(widget_args, {
        widget = wibox.widget.textbox,
        font = get_font(13),
        markup = format_label(label, state.is_keygrabbing)
    }))

    -- TODO top, bottom margins for vertical submenus

    local widget = wibox.widget {
        {
            text,

            layout = wibox.container.margin,

            left = 4,
            right = 4,
            top = 2,
            bottom = 2,
        },

        layout = wibox.container.background
    }

    local menu

    widget:connect_signal("mouse::enter", function()
        widget.bg = config.popup.bg

        if state.is_active and get_menu then
            menu = get_menu(widget)
        end
    end)

    widget:connect_signal("button::press", no_scroll(function(w)
        if handle_click then
            handle_click(w, text)
        end

        state.is_active = not state.is_active

        if state.is_active then
            w:emit_signal("mouse::enter")
        else
            w:emit_signal("mouse::leave")
        end
    end))

    widget:connect_signal("mouse::leave", function()
        -- delay because the leave event might indicate the cursor moving to the child popup
        gtimer.delayed_call(function()
            -- check that this flag actually exists
            local hasnt_entered = menu and menu.has_entered == false

            if not menu or not menu.visible or hasnt_entered then
                widget.bg = nil

                -- more shit
            end

            if menu and hasnt_entered then
                menu:emit_signal("destroy")
            end
        end)
    end)

    return widget
end

return appmenu_button