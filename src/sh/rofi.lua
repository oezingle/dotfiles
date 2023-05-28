
local awful = require("awful")

local config = require("config")
local directories = require("src.util.fs.directories")

local rofi_cmd = string.format("PATH=$PATH:%s %s > /dev/null 2>&1", directories.assets .. "applets", config.apps.rofi)

local function rofi()
    awful.spawn.with_shell(rofi_cmd)
end

return rofi