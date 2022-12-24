local agnostic_spawn = require("src.agnostic.spawn")
local agnostic_print = require("src.agnostic.print")
local gtk_menu_item = require("src.appmenu.gtk.menu_item")
local dbus = require("src.appmenu.dbus")
local flags = require("src.appmenu.flags")
--[[
local Promise = require("src.util.Promise")
local pack = require("src.agnostic.version.pack")
local unpack = require("src.agnostic.version.unpack")
]]

-- dbus GTK menu spec: https://wiki.gnome.org/Projects/GLib/GApplication/DBusAPI#org.gtk.Menus
-- actually pretty useful

-- weak-value table
local gtk_menu_info_cache = setmetatable({}, {
    __mode = "v"
})

--[[
local function spawn_promise(command, ...)
    local args = pack(...)

    return Promise(function(resolve)
        agnostic_spawn(command, function(res)
            resolve(res, unpack(args))
        end)
    end)
end
]]

---@param window_id number XWindow id to get the menu of
---@param callback fun(info: MenuInfo |nil): nil
local function get_gtk_menu_info(window_id, callback)
    local existing_info = gtk_menu_info_cache[window_id]

    if existing_info then
        callback(existing_info)
    else
        --[[
        -- TODO throws an error somewhere
        Promise.resolve()
            :after(function()
                return spawn_promise('xprop -id ' ..
                    tostring(window_id) .. ' _GTK_UNIQUE_BUS_NAME | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"')
            end)
            :after(function(result)
                local service = result:sub(1, -2)

                return #service ~= 0 and service
            end)
            :after(function(service)
                if not service then
                    error("No service")
                end

                return spawn_promise('xprop -id ' ..
                    tostring(window_id) .. ' _GTK_MENUBAR_OBJECT_PATH | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"',
                    service)
            end)
            :after(function(result, service)
                local menu_path = result:sub(1, -2)

                local info = {
                    service = service,
                    path = menu_path
                }

                gtk_menu_info_cache[window_id] = info

                callback(info)

                return info
            end)
            :catch(function ()
                callback(nil)
            end)
            ]]

        agnostic_spawn(
            'xprop -id ' .. tostring(window_id) .. ' _GTK_UNIQUE_BUS_NAME | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"',
            function(result)
                local service = result:sub(1, -2)

                if #service ~= 0 then
                    agnostic_spawn(
                        'xprop -id ' ..
                        tostring(window_id) .. ' _GTK_MENUBAR_OBJECT_PATH | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"',
                        function(result)
                            local menu_path = result:sub(1, -2)

                            local info = {
                                service = service,
                                path = menu_path
                            }

                            gtk_menu_info_cache[window_id] = info

                            callback(info)
                        end
                    )
                else
                    -- not a gtk menu
                    callback(nil)
                end
            end
        )
    end
end

local function get_gtk_menu(window_id, callback)
    get_gtk_menu_info(window_id, function(menu_info)
        if menu_info then
            local path = menu_info.path
            local service = menu_info.service

            if flags.DEBUG then
                agnostic_print(service .. " " .. path)
            end

            local menu_proxy = dbus.new_smart_proxy(service, path, "org.gtk.Menus")
            local actions_proxy = dbus.new_smart_proxy(service, path, "org.gtk.Actions")

            callback(gtk_menu_item(menu_proxy, actions_proxy, 0))
        else
            callback(nil)
        end
    end)
end

return get_gtk_menu
