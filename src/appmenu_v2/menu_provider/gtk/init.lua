
local folder_of_this_file = (...):match("(.-)[^%.]+$")

local gtk_menu_item = require(folder_of_this_file .. "gtk.item")

local base = require("src.appmenu_v2.menu_provider.base")
local Promise = require("src.util.Promise")
local dbus = require("src.util.lgi.dbus")

local spawn = require("src.agnostic.spawn.promise")

local gtk_menu = base:extend("GTKMenu", {
    MENU_TYPE = "GTK",
    ---@type table<number, MenuInfo>
    info_cache = setmetatable({}, {
        __mode = "v"
    })
})

---@param client Client client to get the menu of
---@return Promise<MenuInfo|nil>
local function get_appmenu_information(client)
    local window_id = tonumber(client.window)

    if not window_id then
        error("window_id is not a number")
    end

    return Promise(function(res)
        local existing_info = gtk_menu.info_cache[window_id]

        if existing_info then
            res(existing_info)
        else
            spawn(string.format('xprop -id %s _GTK_UNIQUE_BUS_NAME | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"',
                client.window))
                :after(function(result)
                    local service = result:sub(1, -2)

                    if #service ~= 0 then
                        return true, service
                    else
                        -- not a gtk menu
                        return false
                    end
                end)
                :after(function(is_gtk, service)
                    if is_gtk then
                        return spawn(string.format(
                                'xprop -id %s _GTK_MENUBAR_OBJECT_PATH | grep -oP "\\"\\S+\\"" | grep -oP "[^\\"]+"',
                                client.window))
                            :after(function(menu_path)
                                return menu_path, service
                            end)
                    end
                end)
                :after(function(result, service)
                    if not result then
                        return nil
                    end

                    local menu_path = result:sub(1, -2)

                    local info = {
                        service = service,
                        path = menu_path
                    }

                    gtk_menu.info_cache[window_id] = info

                    return info
                end)
                :after(function (whatever)
                    res(whatever)
                end)
        end
    end)
end

---@param client Client
function gtk_menu:init(client)
    self.client = client
end

function gtk_menu:setup()
    return get_appmenu_information(self.client)
        :after(function(menu_info)
            if not menu_info then
                error("No menu info")
            end

            local service = menu_info.service
            local path = menu_info.path

            local proxies = {
                menu = dbus.new_smart_proxy(service, path, "org.gtk.Menus"),
                actions = dbus.new_smart_proxy(service, path, "org.gtk.Actions")
            }

            self.root = gtk_menu_item(proxies, 0)
        end)
end

function gtk_menu:get_menu()
    return self.root
end

function gtk_menu:get_children()
    return self:get_menu():get_children()
end
function gtk_menu.provides(client)
    return get_appmenu_information(client)
        :after(function(information)
            return information ~= nil
        end)
end

return gtk_menu
