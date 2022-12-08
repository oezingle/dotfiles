-- TODO unused!

local update_widget = require("src.widgets.helper.update")
local config        = require("config")
local no_scroll     = require("src.widgets.helper.no_scroll")

local button_widget = require("src.widgets.util.button")

local function smart_toggle_button(args)
    local state = false

    local function set_state(widget, new_state)
        if type(new_state) ~= "boolean" or state == new_state then
            return
        end

        if args.on_state_change then
            args.on_state_change(new_state)
        end

        if state then
            widget.bg = config.button.active

            widget.old_bg = nil
        else
            widget.bg = config.button.normal
            
            widget.old_bg = nil
        end
    end

    local update_callback = nil
    if args.update_callback then
        update_callback = function(w)
            set_state(w, args.update_callback())
        end
    end

    local button = update_widget {
        widget = button_widget(args.widget),
        update_callback = update_callback
    }

    if args.on_press then
        button:connect_signal("button::press", no_scroll(function (w)
            set_state(w, args.on_press(state))
        end))
    end

    return button
end

return smart_toggle_button
