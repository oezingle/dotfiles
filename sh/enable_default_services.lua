#!/usr/bin/luajit

require("src.amenities.init")

local load_scripts = require("src.awesome.core.load_scripts")
load_scripts.poll()


local Service = require("src.util.Service")
Service.log = log

Service.warn_unregistered()

local defaults = {
    "cli",
    "gc"
}

for _, service in ipairs(defaults) do
    Service.enable(service)
end
