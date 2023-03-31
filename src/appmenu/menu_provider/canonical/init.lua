
local base = require("src.appmenu.menu_provider.base")
local Promise = require("src.util.Promise")
local dbus = require("src.util.lgi.dbus")

local GVariant = require("src.util.lgi.GVariant")
local canonical_menu_item = require("src.appmenu.menu_provider.canonical.item")

local registrar = dbus.new_smart_proxy(
    "com.canonical.AppMenu.Registrar",
    "/com/canonical/AppMenu/Registrar",
    "com.canonical.AppMenu.Registrar"
)

local canonical_menu = base:extend("CanonicalMenu", {
    MENU_TYPE = "Canonical",
    ---@type table<number, {service: string, path: string}>
    info_cache = setmetatable({}, {
        __mode = "v"
    })
})

---@param client Client
---@return Promise<MenuInfo|nil>
local function get_appmenu_information(client)
    local window_id = tonumber(client.window)

    if not window_id then
        error("window_id is not a number")
    end

    return Promise(function(res)
        local existing_info = canonical_menu.info_cache[window_id]

        if existing_info then
            res(existing_info)
        else
            -- needs a tuple for whatever reason
            local window_id_variant = GVariant("(u)", { window_id })

            xpcall(
                function()
                    local menu_info = registrar.method.GetMenuForWindow(window_id_variant)

                    local info = {
                        service = menu_info[1],
                        path = menu_info[2]
                    }

                    canonical_menu.info_cache[window_id] = info

                    res(true)
                end,
                function(err)
                    -- print(debug.traceback(tostring(err)))

                    res(nil)
                end
            )
        end
    end)
end

---@param client Client
function canonical_menu:init(client)
    self.client = client
end

function canonical_menu:setup()
    return get_appmenu_information(self.client)
        :after(function(menu_info)
            if not menu_info then
                error("No menu info")
            end

            local service = menu_info.service
            local path = menu_info.path

            local proxy = dbus.new_smart_proxy(service, path, "com.canonical.dbusmenu")

            self.root = canonical_menu_item(proxy, 0)
        end)
end

function canonical_menu:get_menu()
    return self.root
end

function canonical_menu:get_children()
    return self:get_menu():get_children()
end

function canonical_menu.provides(client)
    return get_appmenu_information(client)
        :after(function(information)
            return information ~= nil
        end)
end

return canonical_menu
