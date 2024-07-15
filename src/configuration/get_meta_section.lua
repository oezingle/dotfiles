local Configuration               = require("src.configuration.Configuration")
local default                     = require("src.configuration.section.default")
local LuaConfigurationProvider    = require("src.configuration.LuaConfigurationProvider")

--- Bootstrap config, getting the meta-config for the config providers
---@return Promise<Zingle.Awesome.Config.Section.Default.meta>
local function get_meta_section ()
    local config = Configuration(default, { LuaConfigurationProvider })

    return config:create_provider()
        :after(function ()
            local baked = config:bake_config()

            if not baked then
                error("Configuration returned nil")
            end
        
            return baked.meta                    
        end)
end

return get_meta_section