
-- Functionality implemented regardless of vanilla Lua or AwesomeWM

local agnostic = {
    print = require("src.agnostic.print"),
    spawn = require("src.agnostic.spawn"),
    cache = require("src.agnostic.cache")
}

return agnostic