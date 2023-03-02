#!/usr/bin/lua

local validate_config = require("src.util.get_config.validate")

local config = require("config")

local success, err = validate_config(config)

if success then
    print("No errors found in config.lua")
else
    if not err then error("error not recieved") end

    print("Error in config.lua:")

    local err_formatted = err:gsub("\n", "\n    ")

    print("    " .. err_formatted)
end