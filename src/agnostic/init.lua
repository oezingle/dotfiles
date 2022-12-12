
-- Functionality implemented regardless of vanilla Lua or AwesomeWM

local agnostic = {
    print = require("src.agnostic.print"),
    spawn = require("src.agnostic.spawn"),
    cache = require("src.agnostic.cache"),
    pack = require("src.agnostic.version.pack"),
    unpack = require("src.agnostic.version.unpack")
}

return agnostic