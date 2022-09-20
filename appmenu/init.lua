local config = require("config")

if not config.gimmicks.global_menu then
    -- return a dummy function and don't let any more memory be wasted
    return function() end
end

-- TODO state.reload() blocks the mainloop for a WHILE

local flags   = require("appmenu.flags")
local confirm = require("widgets.components.confirm")

local pidwatch = require("sh").pidwatch
local get_menu = require("appmenu.get_menu")

local wibox  = require("wibox")
local gdebug = require("gears.debug")

pidwatch("~/.config/awesome/appmenu/server/main")

-- TODO hide menu when mouse has entered and leaves, but not into another menu button?

-- TODO catch errors, reload if menu has changed

local appmenu_button     = require("appmenu.widget.appmenu_button")
local appmenu_menu       = require("appmenu.widget.appmenu_menu")
local recursive_menu_gen = require("appmenu.widget.recursive_menu_gen")

--- Make the first letter of all words in a string uppercase. "hello world" -> "Hello World"
---@param str string
---@return string
local function uppercase_first_letters(str)
    return string.gsub(" " .. str, "%W%l", string.upper):sub(2)
end

-- TODO mouse & keyboard control
-- keyboard combo to stop focus change, lock into global menu
-- arrow keys / enter
-- escape to leave either current menu or if no menus open, global menu mode
-- hover & click effect using a wibox.layout.stack ( so background element can be made truly invisible )
-- implement and call menu_item:hover()

---@alias global_menu_state { is_active: boolean, is_keygrabbing: boolean, reload: fun(client: table) }


local function create_appmenu()
    ---@type global_menu_state
    local state = {
        is_active = false,
        is_keygrabbing = false,
    }

    local global_menu = wibox.widget {
        id = "app-menu",
        layout = wibox.layout.fixed.horizontal,
    }

    local app_menu = global_menu:get_children_by_id("app-menu")[1]

    ---@param c table
    local reload_menu = function(c)
        if flags.DEBUG then
            gdebug.print_warning("Reloading menu")
        end

        ---@param menu MenuItem
        get_menu(tonumber(c.window), function(menu)
            app_menu:reset()

            app_menu:add(appmenu_button(state, '<b>' .. uppercase_first_letters(c.class:gsub("-", " ")) .. '</b>', {
                id = "app-name"
            }, function(button)
                local control_window_menu, items = appmenu_menu(button)

                local menu_type = menu and menu.MENU_TYPE or "[nil]"

                --[[
                items:add(appmenu_button(state, "Move to Tag", {}, function ()
                    -- TODO submenu
                end))
                ]]

                -- Minimize button
                items:add(appmenu_button(state, "Minimize", {}, nil, function()
                    c.minimized = true
                end))

                -- Toggle maximize
                local maximized_string = function() return c.maximized and "Unmaximize" or "Maximize" end

                items:add(appmenu_button(state, maximized_string(), {}, nil, function(_, textbox)
                    c.maximized = not c.maximized

                    textbox.text = maximized_string()
                end))

                -- Toggle sticky
                local sticky_string = function() return c.sticky and "Unsticky" or "Sticky" end

                items:add(appmenu_button(state, sticky_string(), {}, nil, function(_, textbox)
                    c.sticky = not c.sticky

                    textbox.text = sticky_string()
                end))

                -- Quit
                items:add(appmenu_button(state, "Quit", {}, nil, function()
                    confirm(function()
                        c:kill()
                    end, "quit " .. c.class)
                end))

                if flags.DEBUG then
                    items:add(appmenu_button(state, "Menu Type: " .. menu_type))
                end

                return control_window_menu
            end))

            if menu then
                ---@param children MenuItem[]
                menu:get_children(function(children)
                    for _, child in ipairs(children) do
                        -- ignore [Empty_Label]
                        if child.label then
                            -- TODO this button might not have children of its own - then what?
                            local button = appmenu_button(state, child.label, {}, function(button)
                                return recursive_menu_gen(state, child, button)
                            end)

                            app_menu:add(button)
                        end
                    end
                end)
            end
        end)
    end

    state.reload = reload_menu

    client.connect_signal("focus", function(c)
        reload_menu(c)
    end)

    client.connect_signal("unfocus", function()
        app_menu:reset()

        state.is_active = false
    end)

    return global_menu
end

local appmenu

local function get_appmenu()
    if not appmenu then
        appmenu = create_appmenu()
    end

    return appmenu
end

return get_appmenu
