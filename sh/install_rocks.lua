require("src.amenities.init")

local spawn    = require "src.util.spawn.spawn"
local Promise  = require "src.polyfill.Promise"
local MainLoop = require "src.util.lgi.MainLoop"

--[[
This script doesn't default to any installation of lua because we need to determine version based on which lua exec runs it.

An up-to-date list of required rocks can be found by regexing all files in src for
require\("(?!src|spec|config|lib|naughty|awful|gears)
]]

local lua_version = _VERSION:match("^Lua (.*)$")

local rocks = {
    "luafilesystem",
    "luaposix",
    -- required regardless of what regex says
    "busted"
}

local fmt = "luarocks --lua-version %s %s install %s"

local local_flag = ""
if os.getenv("EUID") ~= "0" then
    log.warn(
    "Using local directory for luarocks. This means only your user will have access to these rocks. To change this, run this script as su/root")

    print("Press enter to continue")
    io.read()

    local_flag = "--local"
end

---@type Promise<nil>
local p = Promise.resolve()

local done = false

for _, rock in ipairs(rocks) do
    p = p:after(function()
        local cmd = string.format(fmt, lua_version, local_flag, rock)

        log.info("Running", cmd)

        return spawn(cmd):after(function (ret)
            local out = ret.stdout

            log.info(out)
        end)
    end)
end

local loop = MainLoop()

p:after(function()
    loop:quit()

    done = true
end)

if not done then
    loop:run()
end

log.info("Done!")
