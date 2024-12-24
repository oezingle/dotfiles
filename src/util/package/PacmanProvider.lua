local PackageProvider = require("src.util.package.PackageProvider")

local spawn = require("src.util.spawn")
local which = require("src.util.spawn.which")

---@class Zingle.Awesome.PackageProvider.Pacman : Zingle.Awesome.PackageProvider
local PacmanProvider = PackageProvider:extend("Zingle.Awesome.PackageProvider.Pacman")

function PacmanProvider.can_use()
    return which("pacman")
        :after(function(path)
            return type(path) == "string"
        end)
end

function PacmanProvider:has(package, version)
    -- TODO maybe these two steps should occur on the packagelib side?
    version = version or "any"
    package = self:translate(package)

    local paccmd = string.format("pacman -Q %s", package)

    return spawn(paccmd)
        :after(function(res)
            return res.stdout
        end)
        :after(function(stdout)
            if not stdout then
                return {
                    has = false,
                    version_has = nil,
                    version_wants = version,
                    is_luarock = false,
                    install_name = package
                }
            end

            -- Matches name & version but we ignore version
            local _, match_version = stdout:match("^(%S+)%s(%S+)\n$")

            return {
                has = true,
                version_has = match_version,
                version_wants = version,
                is_luarock = false,
                install_name = package
            }
        end)
end

return PacmanProvider
