local wibox  = require("wibox")
local gtimer = require("gears.timer")

local appmenu_menu = require("src.appmenu.widget.appmenu_menu")
local appmenu_button = require("src.appmenu.widget.appmenu_button")

-- TODO children still kinda iffy
---@param state global_menu_state
---@param menu_item MenuItem
---@param parent table
---@param direction Direction?
local function recursive_menu_gen(state, menu_item, parent, direction)
    local popup, items = appmenu_menu(parent, direction)

    menu_item:get_children(function(children)
        if children then
            -- if there was a reload, the reload came in clutch
            state.has_attempted_reload = false

            for _, child in ipairs(children) do
                child:get_children(function(children)
                    local has_children = #children ~= 0

                    if child.label then
                        local button = appmenu_button(
                            state,
                            child.label,
                            -- no additional widget arguments
                            {},
                            -- get_menu
                            function()
                                if has_children then
                                    popup.child = recursive_menu_gen(state, child, popup, "right")
                                else
                                    -- TODO child:hover()

                                    if popup.child then
                                        popup.child:emit_signal("destroy")
                                    end
                                end
                            end,
                            -- handle_click
                            function()
                                if not has_children then
                                    child:activate()

                                    -- TODO doesn't seem to work
                                    state.is_active = false

                                    -- canonical menus get new ids on every click event
                                    if child.MENU_TYPE == "canonical" then
                                        -- reload menu

                                        -- TODO not in love with this
                                        gtimer.delayed_call(function()
                                            state.reload(client.focus)
                                        end)
                                    end
                                end
                            end
                        )

                        items:add(button)
                    else
                        local spacer = wibox.widget {
                            layout = wibox.container.margin,

                            top = 5,
                        }

                        items:add(spacer)
                    end
                end)
            end
        else
            -- reload state? idk man
            if not state.has_attempted_reload then
                state.reload(client.focus)

                state.has_attempted_reload = true
            end
        end
    end)

    return popup
end

return recursive_menu_gen