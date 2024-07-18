
--[[
    Little script to find the install locations of given packages using pacman
]]

-- TODO FIXME finish this

local spawn_vanilla_sync = require("src.util.spawn.vanilla_sync")

local packages = {
}

for _, package in ipairs(packages) do
    local paccmd = string.format("pacman -Ql %s", package)

    spawn_vanilla_sync(paccmd)
end