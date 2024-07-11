
local semver = require("lib.semver.semver")

--- https://github.com/kikito/semver.lua
--- Typings provided by Zingle

if false then
    ---@class Kikito.Semver
    ---@field major number
    ---@field minor number
    ---@field patch number
    ---@field prerelease nil | "alpha" | "beta"
    ---@field build string
    ---@field nextPatch fun (self: self): Kikito.Semver
    ---@field nextMinor fun (self: self): Kikito.Semver
    ---@field nextMajor fun (self: self): Kikito.Semver

    ---@param version string
    ---@return Kikito.Semver
    ---@overload fun(major: number, minor: number, patch: number, prerelase?: "alpha" | "beta"): Kikito.Semver
    function semver (version)
        return {}
    end
end

-- Can upgrade - old ^ new

return semver