
require("src.amenities.init")

local cli_server = require("src.awesome.services.cli")
local load_scripts = require("src.awesome.core.load_scripts")
local MainLoop = require("src.util.lgi.MainLoop")

local Service = require("src.util.Service")
Service.log = log

load_scripts.poll()

Service.start(cli_server)

local loop = MainLoop()
loop:run()