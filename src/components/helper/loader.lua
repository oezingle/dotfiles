local not_available = require("src.components.helper.not_available")

---@class Zingle.Awesome.Components.Loader.Provider
---@field is_supported boolean|(fun(): boolean)
---@field loaded boolean
---@field components table<string, function>
---@field name string

---@class Zingle.Awesome.Components.Loader
---@field providers Zingle.Awesome.Components.Loader.Provider[]
local loader = {
    providers = {},
    provider_names = {},

    expected = {
        ["Background"] = true,
        ["Center"] = true,
        ["Flex"] = true,
        ["Icon"] = true,
        ["Margin"] = true,
        ["Text"] = true
    }
}

---@param name string
---@param info { is_supported: boolean|(fun(): boolean) }
function loader.create_provider(name, info)
    local provider = {}

    provider.is_supported = info.is_supported

    provider.components = {}
    provider.name = name

    provider.loaded = false

    table.insert(loader.providers, provider)

    loader.provider_names[name] = #loader.providers
end

loader.create_provider("awesome", {
    is_supported = not not awesome
})




---@param provider Zingle.Awesome.Components.Loader.Provider
---@param component string
function loader.get_require_path(provider, component)
    return string.format("src.components.provider.%s.%s", provider.name, component)
end

---@param provider Zingle.Awesome.Components.Loader.Provider
---@param component_name string
function loader.safe_load(provider, component_name)
    if provider.components[component_name] then
        return provider.components[component_name]
    else
        local require_path = loader.get_require_path(provider, component_name)

        local ok, module = pcall(require, require_path)

        if ok then
            provider.components[component_name] = module
        else
            log.error(string.format(
                "Provider %s does not provide component %s: %s",
                provider.name, component_name, module or "unknown error"
            ))

            provider.components[component_name] = not_available(component_name)
        end

        return provider.components[component_name]
    end
end

---@param provider Zingle.Awesome.Components.Loader.Provider | string
function loader.ensure_provider_loaded(provider)
    if type(provider) == "string" then
        local index = loader.provider_names[provider]

        assert(index, string.format("No provider exists by the name %q", provider))

        provider = loader.providers[index]
    end

    if not provider.loaded then
        for component_name in pairs(loader.expected) do
            provider.components[component_name] = loader.safe_load(provider, component_name)
        end

        provider.loaded = true
    end
end

function loader.get_provider()
    -- pass for loaded
    for _, provider in pairs(loader.providers) do
        if provider.loaded then
            return provider
        end
    end

    -- pass for supported
    for _, provider in pairs(loader.providers) do
        local is_supported = provider.is_supported

        if type(is_supported) == "function" then
            is_supported = is_supported()
        end

        if is_supported then
            loader.ensure_provider_loaded(provider)

            return provider
        end
    end
end

---@param component string
function loader.get(component)
    local provider = loader.get_provider()

    return loader.safe_load(provider, component)
end

local loader_mt_event = function (t, ...)
    return t.get(...)
end
return setmetatable(loader, {
    __index = loader_mt_event,
    __call = loader_mt_event
})
