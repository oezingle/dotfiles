local lgi = require("lgi")
local flags = require("src.appmenu.flags")

local GLib = lgi.GLib
local GVariant = GLib.Variant

local canonical_menu_item = require("src.appmenu.canonical.menu_item")

local agnostic_print = require("src.agnostic.print")
local dbus = require("src.util.lgi.dbus")

local app_menu_proxy, err = dbus.new_smart_proxy(
    "com.canonical.AppMenu.Registrar",
    "/com/canonical/AppMenu/Registrar",
    "com.canonical.AppMenu.Registrar"
)

-- Check for a problem with dbus
if err then
    error(err)
end

---@type table<string, {service: string, path: string}>
local canonical_menu_info_cache = setmetatable({}, {
    __mode = "v"
})

--- Get the DBus service and path of a client, or nil
---@param window_id number XWindow id to get the menu of
---@param callback fun(info: MenuInfo |nil): nil
local function get_canonical_menu_info(window_id, callback)
    local existing_info = canonical_menu_info_cache[window_id]

    if existing_info then
        callback(existing_info)
    else
        -- needs a tuple for whatever reason
        local window_id_variant = GVariant("(u)", { window_id })

        xpcall(
            function()
                local res = app_menu_proxy.method.GetMenuForWindow(window_id_variant)
                
                ---@type MenuInfo
                local info = {
                    service = res[1],
                    path = res[2]
                }
    
                canonical_menu_info_cache[window_id] = info
    
                callback(info)
            end,
            function (err)
                if flags.DEBUG then
                    agnostic_print(err)
                end

                callback(nil)
            end
        )            
    end
end

--- Get the DBus menu of a client, or nil
local function get_canonical_menu(window_id, callback)
    get_canonical_menu_info(window_id, function(menu_info)
        if menu_info then
            local service = menu_info.service
            local path = menu_info.path

            if flags.DEBUG then
                agnostic_print(service .. " " .. path)
            end

            local proxy = dbus.new_smart_proxy(service, path, "com.canonical.dbusmenu")

            callback(canonical_menu_item(proxy, 0))
        else
            callback(nil)
        end
    end)
end

return get_canonical_menu
