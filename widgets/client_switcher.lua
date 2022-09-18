local awful  = require("awful")
local wibox  = require("wibox")
local shapes = require("util.shapes")
local config = require("config")
local no_scroll = require("widgets.helper.no_scroll")

local get_font = require("util.get_font")

local client_content_preview = require("widgets.components.client_preview")
local client_true_geometry   = require("util.client.true_geometry")
local clienticon_or_xorg = require("widgets.components.clienticon_or_xorg")

local module_name = "client_switcher"

local PREVIEW_SIZE = 128

-- TODO acts iffy on first use

-- prview the client - content if visible, icon if invisible
local function client_preview(c)
    if c:isvisible() then
        -- TODO cairo INVALID_MATRIX error
        return client_content_preview(c)
    else
        local geo = client_true_geometry(c)

        -- we know that the place is maximized to 128x128, so we can safely use that as our maximum
        -- saves the headache of making another widget just to get width and height
        local scale = math.min(PREVIEW_SIZE / geo.width, PREVIEW_SIZE / geo.height)

        return wibox.widget {
            {
                clienticon_or_xorg(c),

                layout = wibox.container.place
            },

            layout = wibox.container.background,

            forced_width = geo.width * scale,
            forced_height = geo.height * scale,

            bg = config.popup.bg
        }
    end
end

local function create_client_switcher()
    local popup_widget = wibox.widget {
        layout = wibox.container.margin,
        margins = 10,
        {
            {
                {
                    widget = wibox.widget.textbox,
                    text = "[Placeholder]",
                    id = "tag-name",

                    font = get_font(18)
                },
                nil,
                {
                    {
                        -- TODO fix
                        -- awful.widget.layoutbox(s),

                        forced_width = 24,
                        forced_height = 24,

                        layout = wibox.container.place,
                    },

                    layout = wibox.container.place,
                },

                layout = wibox.layout.align.horizontal,
                expand = "inside"
            },

            {
                layout  = wibox.layout.fixed.horizontal,
                spacing = 5,

                id = "client-list"
            },

            layout = wibox.layout.fixed.vertical,
            spacing = 10,
        }
    }

    local client_list = popup_widget:get_children_by_id("client-list")[1]

    local function client_select_widget(c)
        local widget = wibox.widget {
            {
                {
                    {
                        {
                            client_preview(c),

                            layout = wibox.container.background,

                            shape = shapes.rounded_rect(),
                            shape_border_color = c.decoration_color,
                            shape_border_width = 1,
                        },
                        forced_width = PREVIEW_SIZE,
                        forced_height = PREVIEW_SIZE,

                        layout = wibox.container.place
                    },
                    {
                        {
                            {
                                {
                                    widget = clienticon_or_xorg,

                                    forced_width = 16,
                                    forced_height = 16,

                                    client = c,
                                },

                                widget = wibox.container.place,
                            },
                            {
                                widget = wibox.widget.textbox,
                                text = c.class,

                                font = get_font(12)
                            },
                            layout = wibox.layout.fixed.horizontal,
                            spacing = 5
                        },
                        layout = wibox.container.place
                    },

                    layout = wibox.layout.fixed.vertical,
                    spacing = 15
                },
                layout = wibox.container.margin,
                margins = 5,
            },
            layout = wibox.container.background,

            shape = shapes.rounded_rect(),

            bg = config.button.normal
        }

        widget:connect_signal("mouse::enter", function()
            widget.bg = config.button.hover
        end)

        widget:connect_signal("mouse::leave", function()
            widget.bg = config.button.normal
        end)

        widget:connect_signal("button::press", no_scroll(function()
            awesome.emit_signal(module_name .. "::hide")

            c:jump_to()
        end))

        return widget
    end

    local function update()
        local s = awful.screen.focused()

        local t = s.selected_tag

        popup_widget:get_children_by_id("tag-name")[1].text = "Tag " .. t.name

        client_list:reset()

        for _, c in ipairs(t:clients()) do
            -- Temp widget
            client_list:add(client_select_widget(c))
        end
    end

    local popup = awful.popup {
        widget = popup_widget,

        placement = awful.placement.centered,

        ontop = true,
        visible = false,

        shape = shapes.rounded_rect(),

        bg = config.popup.bg,
        fg = config.popup.fg
    }

    local function hide()
        client_list:reset()

        popup.visible = false
    end

    local function show()
        update()

        popup.visible = true

        popup.screen = awful.screen.focused()

        local client_index = 0

        local function update_client_index(amt)
            local client_list_children = client_list:get_children()

            if client_list_children[client_index] then
                client_list_children[client_index]:emit_signal("mouse::leave")
            end

            client_index = client_index + amt

            if client_index > #client_list_children then
                client_index = 1
            elseif client_index < 1 then
                client_index = #client_list_children
            end

            if client_list_children[client_index] then
                client_list_children[client_index]:emit_signal("mouse::enter")
            end
        end

        -- TODO mouse mode 
        -- emit mouse::leave to client_list_children[client_index] if triggered by keyboard event and mouse starts moving
        
        update_client_index(1)

        awful.keygrabber {
            keybindings        = {
                {
                    { 'Mod1' }, 'Tab',
                    function()
                        update_client_index(1)
                    end
                },
                {
                    { 'Mod1', 'Shift' }, 'Tab',
                    function()
                        update_client_index(-1)
                    end
                },
            },
            -- Note that it is using the key name and not the modifier name.
            stop_key           = 'Mod1',
            stop_event         = 'release',
            start_callback     = awful.client.focus.history.disable_tracking,
            stop_callback      = function()
                awful.client.focus.history.enable_tracking()

                if client_index then
                    local client_list_children = client_list:get_children()

                    local child = client_list_children[client_index]

                    -- fix some weird bug from mouse selection
                    if child then
                        child:emit_signal("button::press")
                    end
                end

                hide()
            end,
            export_keybindings = true,
        }
    end

    local function_names = {
        update = update,
        show   = show,
        hide   = hide,
    }

    for name, fn in pairs(function_names) do
        awesome.connect_signal(module_name .. "::" .. name, fn)
    end


    tag.connect_signal("property::selected", function()
        hide()
    end)
end

return create_client_switcher