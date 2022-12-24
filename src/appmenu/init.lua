local config = require("config")

if not config.gimmicks.global_menu then
    -- return a dummy function and don't let any more memory be wasted
    return function() end
end

-- TODO state.reload() is bad pattern

local flags   = require("src.appmenu.flags")

local pidwatch = require("src.sh").pidwatch
local get_menu = require("src.appmenu.get_menu")

local wibox  = require("wibox")
local gdebug = require("gears.debug")

local directories = require("src.util.fs.directories")

-- TODO assumes a folder
pidwatch(directories.config .. "src/appmenu/server/main")

local appmenu_button          = require("src.appmenu.widget.appmenu_button")
local appmenu_menu            = require("src.appmenu.widget.appmenu_menu")
local recursive_menu_gen      = require("src.appmenu.widget.recursive_menu_gen")
local uppercase_first_letters = require("src.util.uppercase_first_letters")

-- TODO keyboard control
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

    local last_reload_client = nil
    local reload_attempts = 0

    ---@param c table
    local reload_menu = function(c)
        if last_reload_client == c then
            reload_attempts = reload_attempts + 1
        else
            last_reload_client = c
            reload_attempts = 0
        end

        if reload_attempts > 5 then
            -- give up on reloading

            local err = "Failed to reload menu for client " .. c.name .. " after 5 attempts. X ID: " .. c.window

            gdebug.print_warning(err)

            awesome.emit_signal("debug::error", err)

            return
        end

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
                    c:kill()
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
                                local success, res_or_err = pcall(function()
                                    return recursive_menu_gen(state, child, button)
                                end)

                                if not success then
                                    gdebug.print_warning("Menu error: " .. tostring(res_or_err))

                                    state.reload(c)
                                else
                                    return res_or_err
                                end
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

-- strawman function
local function get_appmenu()
    if not appmenu then
        appmenu = create_appmenu()
    end

    return appmenu
end

return get_appmenu
