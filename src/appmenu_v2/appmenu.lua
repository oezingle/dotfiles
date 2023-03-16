local Promise = require("src.util.Promise")

local canonical_menu = require("src.appmenu_v2.menu_provider.canonical")
local gtk_menu = require("src.appmenu_v2.menu_provider.gtk")

-- TODO icons - kde specialty?

-- TODO implement sections on menus
-- - already there for GTK, just don't resolve items as if sections don't exist
-- - squeeze ever item into a single section for canonical
-- - section widgets have margins unless they're the last child

-- visual for if a menu item has children
-- - MenuItem:has_children() - saves system from doing constant reloads to check for child items under canonical

---@class Appmenu
---@field client Client|nil
---@field providers MenuProvider[]
local appmenu = {
    client = nil,
    providers = {
        gtk_menu,
        canonical_menu
    }
}

---@param client Client
function appmenu.set_client(client)
    appmenu.client = client
end

local function list_iter(t)
    local i = 0
    local n = #t
    return function()
        i = i + 1
        if i <= n then return t[i] end
    end
end

-- TODO test
---@return Promise<MenuProvider|nil>
function appmenu._find_provider()
    local client = appmenu.client

    if not client then
        return Promise.resolve(nil)
    end

    local iproviders = list_iter(appmenu.providers)

    local function test_next_provider()
        local provider = iproviders()

        if not provider then
            return Promise.resolve(nil)
        end

        return provider.provides(client)
            :after(function(provides)
                if provides then
                    return provider
                else
                    return test_next_provider()
                end
            end)
    end

    return test_next_provider()
end

-- TODO cache provider, changing only if client changes or appmenu.reload()

---@return Promise<MenuProvider|nil>
function appmenu.load_provider()
    return appmenu._find_provider()
        :after(function(provider)
            if provider then
                return provider(appmenu.client)
            end

            return provider
        end)
        :after(function(provider)
            -- Call the provider's setup function, if it exists

            if provider and provider.setup then
                local setup_return = provider:setup()

                -- Setup can return any, but may return a promise.
                -- If so, insert this setup callback into the chain
                if setup_return and type(setup_return) == "table" and setup_return.__is_a_promise then
                    return setup_return:after(function()
                        return provider
                    end)
                end
            end

            return provider
        end)
end

function appmenu.get()
    return appmenu.load_provider()
        :after(function(provider)
            if not provider then
                return nil
            end

            return provider:get_menu():get_children()
        end)
        :catch(function(err)
            print(debug.traceback(tostring(err)))
        end)
end

return appmenu
