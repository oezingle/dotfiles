local fs            = require("src.util.fs")
local not_available = require("src.components.helper.not_available")


local loader = {}


loader.providers = {
    "awesome",
}

---@return Zingle.Awesome.Components.Provider
function loader.determine_provider()
    if awesome then
        return "awesome"
    end

    error("Unable to determine current component provider")
end

---@param provider Zingle.Awesome.Components.Provider
---@param component string
function loader.build_path(provider, component)
    return string.format("src.components.%s.%s", provider, component)
end

---@return boolean ok, string? err
function loader.search_and_assert(provider, component)
    local luapath = loader.build_path(provider, component)

    local filepath, err = package.searchpath(luapath, package.path)

    if not filepath then
        return false, "Unable to resolve a real path for the expected component"
    end

    local exists = fs.exists(filepath)

    if not exists then
        return false, "An error occured while retrieving the component file"
    end

    return true
end

---@param provider Zingle.Awesome.Components.Provider
---@param component string
---@param explicits table<Zingle.Awesome.Components.Provider, string?>
---@return boolean ok, string? err
function loader.is_provided(provider, component, explicits)
    if explicits[provider] then
        return true
    end

    return loader.search_and_assert(provider, component)
end

---@param component string
---@param explicits table<Zingle.Awesome.Components.Provider, string?>
function loader.ensure_all_provide(component, explicits)
    for _, provider in pairs(loader.providers) do
        local is_provided, err = loader.is_provided(provider, component, explicits)

        if not is_provided then
            log.error(string.format(
                "Provider %s does not provide component %s: %s",
                provider, component, err or "unknown error"
            ))
        end
    end
end

---@param component string
---@param explicits table<Zingle.Awesome.Components.Provider, string?>?
function loader.autoload(component, explicits)
    local explicits = explicits or {}

    loader.ensure_all_provide(component, explicits)

    local provider = loader.determine_provider()

    local is_provided, err = loader.is_provided(provider, component, explicits)

    if not is_provided then
        log.error(string.format(
            "Provider %s does not provide component %s: %s",
            provider, component, err or "unknown error"
        ))

        return not_available(component)
    end

    local luapath = loader.build_path(provider, component)

    local ok, module = pcall(require, luapath)

    if ok then
        return module
    end

    local err = module

    log.error(string.format(
        "An error occured when loading component %s from provider %s: %s",
        component, provider, err or "Unknown"
    ))

    return not_available(component)
end

log.info(string.format("Using LuaX component provider %s", loader.determine_provider()))

return loader
