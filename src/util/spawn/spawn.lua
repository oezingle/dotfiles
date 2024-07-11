
-- This code has been grandmothered in from my previous config and may not work! hehe!

local Promise = require("src.polyfill.Promise")
local spawn_vanilla_sync = require("src.util.spawn.vanilla_sync")
local has_awful = pcall(require, "awful")

--- Lua wiki tells lies. maybe this comes in a future update.
---@class Awesome.SpawnReturn 
---@field stdout string Output on stdout. 
-- ---@field stderr string Output on stderr. 
-- ---@field exitreason "exit" | "signal" Exit reason
-- ---@field exitcode number Exit code (exit code or signal number, depending on “exitreason”). 

local spawn

if has_awful then
    local awful_spawn = require("awful.spawn")

    ---@param cmd string
    ---@param cb (fun(result: Awesome.SpawnReturn): nil)?
    spawn = function(cmd, cb)
        if cb then
            return awful_spawn.easy_async_with_shell(cmd, function (ret)
                cb({
                    stdout = ret
                })
            end)
        else
            return awful_spawn.with_shell(cmd)
        end
    end
else
    ---@param cmd string
    ---@param cb (fun(result: Awesome.SpawnReturn): nil)?
    spawn = function (cmd, cb)
        local result = spawn_vanilla_sync(cmd)

        if cb then
            cb({
                stdout = result,
                -- stderr = "",
                -- exitcode = 0,
                -- exitreason = "exit"
            })
        end
    end
end

---@param command string
---@return Promise<Awesome.SpawnReturn>
local function spawn_promise(command)
    return Promise(function(res)
        spawn(command, res)
    end)
end

return spawn_promise