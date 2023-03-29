local Promise = require("src.util.Promise")

local canonical_menu = require("src.appmenu_v2.menu_provider.canonical")
local gtk_menu = require("src.appmenu_v2.menu_provider.gtk")

local traceback = debug.traceback

-- TODO icons - kde specialty?

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

--- Change the client the appmenu uses
---@param client Client | nil
---@return boolean changed if the client is different to the client the menu is currently displaying
function appmenu.set_client(client)
    if appmenu.client == client then
        return false
    else
        appmenu.client = client

        return true
    end
end

--- Get the client the appmenu is using
---@return Client|nil
function appmenu.get_client()
    return appmenu.client
end

local function list_iter(t)
    local i = 0
    local n = #t
    return function()
        i = i + 1
        if i <= n then return t[i] end
    end
end

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
            :catch(function(err)
                print(traceback(tostring(err)))
            end)
    end

    return test_next_provider()
end

-- TODO cache provider, changing only if client changes or appmenu.reload()

---@return Promise<MenuProvider|nil>
function appmenu.load_provider()
    return appmenu._find_provider()
        :after(function(provider)
            -- Instantiation
            if provider then
                return provider(appmenu.client)
            end

            return nil
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
        :catch(function(err)
            print(traceback(tostring(err)))
        end)
end

---@return Promise<MenuItem|nil>
function appmenu.get()
    return appmenu.load_provider()
        :after(function(provider)
            if not provider then
                return nil
            end

            return provider:get_menu()
        end)
        :catch(function(err)
            print(traceback(tostring(err)))
        end)
end

return appmenu
