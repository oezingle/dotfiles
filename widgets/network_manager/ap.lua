-- functions for Access Points

local NM = require("widgets.network_manager.nm")()

local function ssid_to_utf8(ap)
    local ssid = ap:get_ssid()
    if not ssid then return "" end
    return NM.utils_ssid_to_utf8(ssid:get_data())
end

local function get_security(ap)
    local function is_empty(t)
        local next = next
        if next(t) then return false else return true end
    end

    local flags = ap:get_flags()
    local wpa_flags = ap:get_wpa_flags()
    local rsn_flags = ap:get_rsn_flags()

    flags["NONE"] = nil
    wpa_flags["NONE"] = nil
    rsn_flags["NONE"] = nil

    local str = ""
    if flags["PRIVACY"] and is_empty(wpa_flags) and is_empty(rsn_flags) then
        str = str .. " WEP"
    end
    if not is_empty(wpa_flags) then
        str = str .. " WPA1"
    end
    if not is_empty(rsn_flags) then
        str = str .. " WPA2"
    end
    if wpa_flags["KEY_MGMT_802_1X"] or rsn_flags["KEY_MGMT_802_1X"] then
        str = str .. " 802.1X"
    end
    return (str:gsub("^%s", ""))
end

-- Return the first saved connection for a network
-- Ignores multiple conections, too bad!
local function get_first_connection(device, ap)
    for _, connection in ipairs(device:get_available_connections()) do
        if ap:connection_valid(connection) then
            return connection
        end
    end

    return nil
end

return {
    get_security = get_security,
    ssid_to_utf8 = ssid_to_utf8,
    get_first_connection = get_first_connection
}
