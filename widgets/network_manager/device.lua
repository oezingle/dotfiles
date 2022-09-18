local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")

local shapes = require("util.shapes")
local config = require("config")

local spairs = require("util.spairs")

local button_widget = require("widgets.util.button")
local switch_widget = require("widgets.components.switch")

local NM     = require("widgets.network_manager.nm")()
local client = require("widgets.network_manager.client")()

local saved_connections       = require("widgets.network_manager.subwidget.saved_connections")
local view_saved_connections  = saved_connections.view_saved_connections
local ap                      = require("widgets.network_manager.ap")
local connect_to_access_point = require("widgets.network_manager.connection").connect_to_access_point
local ssid_to_utf8            = ap.ssid_to_utf8
local get_security            = ap.get_security

local function sort_aps(t, a, b)
    return t[a]:get_strength() > t[b]:get_strength()
end

-- Filter out duplicates, sort by signal strength
local function get_aps(device)
    local aps = device:get_access_points()

    local hash = {}
    local res = {}

    for _, ap in spairs(aps, sort_aps) do
        local value = ssid_to_utf8(ap)

        if not hash[value] then
            hash[value] = true

            res[#res + 1] = ap
        end
    end

    return res
end

local function save_current_connection(device)
    local connection = device:get_active_connection()

    if connection then
        local remote_connection = connection:get_connection()

        if remote_connection:get_unsaved() then
            client:add_connection_async(remote_connection, true, nil, function(c, result)
                local _, err = c:add_connection_finish(result)

                if err then
                    naughty.notify {
                        text = "Error saving current connection: " .. tostring(err)
                    }
                end
            end)
        else
            naughty.notify {
                text = "Connection not saved: Already saved!"
            }
        end
    else
        naughty.notify {
            text = "Connection not saved: No connection present!"
        }
    end
end

local function interface_widget(device, inner)
    inner = inner or nil

    local interface = device[NM.DEVICE_INTERFACE]

    local type = device:get_device_type()

    local state = device:get_state()

    return wibox.widget {
        {
            {
                {
                    widget = wibox.widget.textbox,
                    font = "Inter Regular 10",
                    text = interface
                },
                {
                    widget = wibox.widget.textbox,
                    font = "Inter Regular 8",
                    text = type .. " ",
                    align = "right"
                },
                switch_widget(
                    function(state)
                        if state then
                            -- enable
                            client:activate_connection_async(nil, device, nil)

                            -- reload and hope that activation takes < 10s
                            for time = 1, 5 do
                                gears.timer {
                                    timeout     = 2 * time,
                                    single_shot = true,
                                    autostart   = true,
                                    callback    = function()
                                        awesome.emit_signal("module::network:update")
                                    end
                                }
                            end
                        else
                            -- disable
                            device:disconnect()
                        end

                        awesome.emit_signal("module::network:update")
                    end,
                    state == "ACTIVATED"
                ),
                layout = wibox.layout.align.horizontal,
                expand = "inside",
            },
            inner,
            {
                button_widget(
                    {
                        widget = wibox.container.margin,
                        margins = 2,
                        {
                            widget = wibox.widget.textbox,
                            text = "Save Current Connection"
                        }
                    },
                    function()
                        save_current_connection(device)
                    end
                ),
                button_widget(
                    {
                        widget = wibox.container.margin,
                        margins = 2,
                        {
                            widget = wibox.widget.textbox,
                            text = "Saved Connections"
                        }
                    },
                    function()
                        view_saved_connections(device)
                    end
                ),
                layout = wibox.layout.flex.horizontal,
                spacing = 5
            },
            spacing = 5,
            layout = wibox.layout.fixed.vertical
        },
        widget = wibox.container.margin,
        top = 15,
        bottom = 1,
    }
end

local function wifi_widget(device)
    local widget = wibox.widget {
        widget = wibox.container.margin,
        left = 5,
        {
            id = "wifi-networks",
            layout = wibox.layout.fixed.vertical
        },
    }

    local network_list = widget:get_children_by_id("wifi-networks")[1]

    local active_ap = device:get_active_access_point()

    for _, ap in ipairs(get_aps(device)) do
        local strength = tonumber(ap:get_strength())

        local security = get_security(ap)

        local ssid = ssid_to_utf8(ap)

        if ssid ~= "" then
            local ap_button = button_widget(
                {
                    {
                        {
                            widget = wibox.widget.textbox,
                            text = ssid
                        },
                        {
                            widget = wibox.widget.textbox,
                            text = security .. " ",
                            align = "right"
                        },
                        {
                            widget = wibox.widget.progressbar,
                            max_value = 100,
                            value = strength,

                            forced_width = 100,
                            forced_height = 3,
                            shape = shapes.rounded_rect(100),

                            color = config.progressbar.fg,
                            background_color = config.progressbar.bg,
                        },
                        layout = wibox.layout.align.horizontal,
                        expand = "inside"
                    },
                    widget = wibox.container.margin,
                    margins = 3
                },
                function(w)
                    connect_to_access_point(device, ap)
                end,
                nil,
                false
            )

            if active_ap and ssid_to_utf8(active_ap) == ssid_to_utf8(ap) then
                ap_button.bg = config.button.active
            end

            network_list:add(wibox.widget {
                ap_button,
                widget = wibox.container.margin,
                margins = 2
            })
        end
    end

    return interface_widget(device, widget)
end

return {
    interface_widget = interface_widget,
    wifi_widget      = wifi_widget
}
