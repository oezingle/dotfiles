local NM = require("src.widgets.network_manager.nm")()
local client = require("src.widgets.network_manager.client")()
local no_scroll = require("src.widgets.helper.no_scroll")

local exitable_dialog = require("src.widgets.util.exitable_dialog")
local textinput = require("src.widgets.components.textinput")
local button_widget = require("src.widgets.util.button")

local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")

local ap = require("src.widgets.network_manager.ap")
local ssid_to_utf8 = ap.ssid_to_utf8
local get_first_connection = ap.get_first_connection

-- Security flags 'reference'
-- https://developer-old.gnome.org/libnm/stable/libnm-nm-dbus-interface.html#NM80211ApSecurityFlags
-- https://developer-old.gnome.org/libnm/stable/NMAccessPoint.html (scroll to flag getters)

local function uuid()
    math.randomseed(os.time())
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function (c)
      local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
      return string.format('%x', v)
    end)
    return uuid
  end

local REQUIRES_USER_INPUT = -1

-- get security info from the user as a widget
local function get_user_info(device, ap, callback)
    local flagses = {
        flags = ap:get_flags(),
        wpa_flags = ap:get_wpa_flags(),
        rsn_flags = ap:get_rsn_flags()
    }

    local security = {}

    -- TODO more network types

    if flagses.flags.PRIVACY then
        security.secure = true

        if flagses.rsn_flags.KEY_MGMT_PSK then
            print("Enter WiFi Passkey: ")
            security.passkey = REQUIRES_USER_INPUT
        end
    end

    if security.secure then
        local inputs = {}

        local function update_security()
            for key, input in pairs(inputs) do
                security[key] = input:get_text()
            end
        end

        local button = button_widget(
            {
                widget = wibox.container.margin,
                magins = 5,
                {
                    widget = wibox.widget.textbox,
                    text = "Confirm"
                }
            }
        )

        local widget = wibox.widget {
            {
                widget = wibox.widget.textbox,
                text = "Authentication Required for " .. ssid_to_utf8(ap),
                font = "Inter Regular 12",
            },
            {
                id = "input-area",
                layout = wibox.layout.fixed.vertical
            },
            button,
            layout = wibox.layout.fixed.vertical,
            spacing = 10
        }

        local input_area = widget:get_children_by_id("input-area")[1]

        for key, value in pairs(security) do
            if value == REQUIRES_USER_INPUT then
                inputs[key] = textinput {
                    forced_width = 256
                }

                input_area:add(wibox.widget {
                    layout = wibox.layout.fixed.vertical,
                    {
                        widget = wibox.widget.textbox,
                        text = "Attribute " .. key
                    },
                    inputs[key]:get_widget()
                })
            end
        end

        local dialog = exitable_dialog {
            widget = widget,
            visible = true
        }

        button:connect_signal("button::press", no_scroll(function()
            update_security()

            callback(device, ap, security)

            dialog.visible = false
        end))
    else
        callback(device, ap, security)
    end


end

local function create_profile(device, ap, security)
    local profile = NM.SimpleConnection.new()

    local s_con = NM.SettingConnection.new()

    -- name after SSID
    s_con[NM.SETTING_CONNECTION_ID] = ssid_to_utf8(ap)
    s_con[NM.SETTING_CONNECTION_UUID] = uuid()

    -- based on /etc/NetworkManager/system-connections/Autobahn.nmconnection
    s_con[NM.SETTING_CONNECTION_TYPE] = "802-11-wireless"

    -- restrict to device by name
    s_con[NM.SETTING_CONNECTION_INTERFACE_NAME] = device[NM.DEVICE_INTERFACE]

    profile:add_setting(s_con)

    local s_wireless = NM.SettingWireless.new()

    s_wireless[NM.SETTING_WIRELESS_SSID] = ap:get_ssid()

    profile:add_setting(s_wireless)

    -- Headbash into getting WPA working
    if security.secure then
        local s_wireless_secure

        s_wireless_secure = NM.SettingWirelessSecurity.new()

        if security.passkey then
            s_wireless_secure[NM.SETTING_WIRELESS_SECURITY_PSK] = security.passkey
        end

        s_wireless_secure[NM.SETTING_WIRELESS_SECURITY_KEY_MGMT] = "wpa-psk"

        profile:add_setting(s_wireless_secure)
    end

    return profile
end

-- Reload every 2s for 10s
local function reload_network_gui()
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
end

-- 5 hours in network manager docs hell for this
local function create_and_activate_connection_and_reload(device, ap)
    -- stop auto reconnect? maybe?
    device:disconnect()

    get_user_info(device, ap, function(device, ap, security)
        local connection = create_profile(device, ap, security)

        client:activate_connection_async(connection, device, nil, nil, function(c, res)
            local _, err = c:activate_connection_finish(res, nil)

            if err then
                naughty.notify {
                    text = "Error connecting to WiFi: ".. tostring(err)
                }
            else
                reload_network_gui()
            end

            -- TODO detect error when connection comes back fine, is loaded, fails, unloads
        end)
    end)
end

local function activate_connection_and_reload(device, connection)
    client:activate_connection_async(connection, device, nil, nil, function()
        reload_network_gui()
    end)
end

local function delete_connection (connection) 
    connection:delete_async(nil, function (conn, res)
        local success, err = conn:delete_finish(res)

        if err then
            naughty.notify {
                text = "Error deleting connection: ".. tostring(err)
            }
        else
            awesome.emit_signal("module::network:update")
        end
    end)
end

local function connect_to_access_point(device, ap)
    -- check if an existing connection can be leveraged

    local connection = get_first_connection(device, ap)

    if connection then
        activate_connection_and_reload(device, connection)
    else
        create_and_activate_connection_and_reload(device, ap)
    end
end

return {
    delete_connection = delete_connection,
    activate_connection_and_reload = activate_connection_and_reload,
    create_and_activate_connection_and_reload = create_and_activate_connection_and_reload,
    connect_to_access_point = connect_to_access_point,
}