local LuaRocksProvider = require("src.util.package_manager.LuaRocksProvider")

---@class Zingle.Awesome.PackageLib
---@field info fun(name: string, version: string?): Promise<Zingle.Awesome.PackageInfo>
---@field install fun(packageinfo: Zingle.Awesome.PackageInfo): Promise<boolean>
local package_manager = {}

---@type Zingle.Awesome.PackageProvider
package_manager.provider = nil

package_manager.rockprovider = LuaRocksProvider()

---@class Zingle.Awesome.PackageInfo.Query
---@field version_wants string?
---@field name string
---@field install_name string?

---@class Zingle.Awesome.PackageInfo : Zingle.Awesome.PackageInfo.Query
---@field has boolean
---@field version_has string?
---@field is_luarock boolean
---@field license string?
---@field url string?
---@field description string?
---@field location string?
---@field install_name string

--[[
---@param name string
---@param version string?
---@return Promise<Zingle.Awesome.PackageInfo>
function package_manager.info(name, version)
    version = version or "any"
    local install_name = package_manager.provider:translate(name)

    local info = package_manager.provider:has(install_name, version)

    return Promise:resolve(info)
        ---@param info Zingle.Awesome.PackageInfo
        :after(function(info)
            info.name = name
        end)
end

---@param packageinfo Zingle.Awesome.PackageInfo
function package_manager.install(packageinfo)
    return package_manager.provider:install(packageinfo)
        :after(function(ok)
            if not ok then
                error("oh man")
            end
        end)
end
]]

---@param packageinfo Zingle.Awesome.PackageInfo.Query | string
function package_manager.rock_install(packageinfo)
    if type(packageinfo) == "string" then
        packageinfo = { name = packageinfo } --[[ @as any ]]
    end

    local provider = package_manager.rockprovider

    return provider:has(packageinfo.name, packageinfo.version_wants)
        :after(function(info)

            if info.has then
                local require_ok = pcall(require, packageinfo.install_name or packageinfo.name)

                if not require_ok then
                    log.debug("require(%q) failed, even though a luarock is found. Installing locally.", packageinfo.install_name or packageinfo.name)

                    info.has = false
                end
            end

            if not info.has then
                return provider:install(packageinfo)
            end
        end)
end

--[[
---@param name string
---@param version string?
---@return Promise<Zingle.Awesome.PackageInfo>
function packagelib.luarock(name, version)
    version = version or "any"
    name = packagelib.provider:
end
]]

return package_manager
