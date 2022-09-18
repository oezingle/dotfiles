
-- Functionality implemented regardless of vanilla Lua or AwesomeWM

local agnostic = {
    print = require("agnostic.print"),
    spawn = require("agnostic.spawn"),
    cache = require("agnostic.cache")
}

return agnostic