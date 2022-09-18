local config = require("config")

if not config.gimmicks.global_menu then
    -- return a dummy function and don't let any more memory be wasted
    return function() end
end

-- TODO state.reload() blocks the mainloop for a WHILE

local flags     = require("appmenu.flags")
local confirm   = require("widgets.components.confirm")
local no_scroll = require("widgets.helper.no_scroll")

local pidwatch = require("sh").pidwatch
local get_menu = require("appmenu.get_menu")

local wibox  = require("wibox")
local awful  = require("awful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gdebug = require("gears.debug")

local get_font = require("util.get_font")

pidwatch("~/.config/awesome/appmenu/server/main")

-- TODO hide menu when mouse has entered and leaves, but not into another menu button?

-- TODO catch errors, reload if menu has changed

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

---@param parent table
---@param direction Direction?
local function appmenu_menu(parent, direction)
    local items = wibox.widget {
        layout = wibox.layout.fixed.vertical
    }

    -- TODO mouse::leave - check for child. if no child, bubble w/ emit_signal to parent

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

        gtimer.delayed_call(function()
            if popup.child and not popup.child.has_entered then
                popup.child:emit_signal("destroy")
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

local function get_appmenu ()
    if not appmenu then
        appmenu = create_appmenu()
    end 

    return appmenu
end

return get_appmenu
