local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local config = require("config")

---@param parent table
---@param direction Direction? the direction relative to the parent
local function appmenu_menu(parent, direction)
    local items = wibox.widget {
        layout = wibox.layout.fixed.vertical
    }

    direction = direction or "bottom"

    local popup = awful.popup {
        widget = items,

        ontop = true,
        visible = true,

        bg = config.taskbar.bg,
        fg = config.popup.fg,

        preferred_positions = { direction }
    }

    popup.child = nil
    popup.has_entered = false

    popup:connect_signal("mouse::enter", function()
        popup.has_entered = true
    end)

    popup:connect_signal("mouse::leave", function()
        -- TODO somehow gets triggered
        if not popup then return end

        if not popup.child or not popup.child.visible then
            popup.visible = false

            gtimer.delayed_call(function()
                popup = nil

                if parent then
                    parent:emit_signal("mouse::leave")
                end
            end)
        end

        local child = popup.child

        gtimer.delayed_call(function()
            if popup then
                child = popup.child
            end
            
            if child and not child.has_entered then
                child:emit_signal("destroy")
            end
        end)
    end)

    popup:connect_signal("destroy", function()
        -- TODO somehow gets triggered
        if not popup then return end

        popup.visible = false

        gtimer.delayed_call(function()
            popup = nil
        end)

        if popup.child and not popup.child.has_entered then
            popup.child:emit_signal("destroy")
        end
    end)

    -- Move to mouse
    do
        ---@type Geometry
        local geo = mouse.current_widget_geometry
        if geo then
            geo.x = geo.x - geo.width

            geo.y = geo.y - geo.height

            -- move to mouse
            popup:move_next_to(geo)
        end
    end

    return popup, items
end

return appmenu_menu