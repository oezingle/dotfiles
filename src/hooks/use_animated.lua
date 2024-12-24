-- TODO FIXME only works under awesome

local Animated = require("src.awesome.Animated")
local use_state = require("lib.LuaX.hooks.use_state")
local use_memo = require("lib.LuaX.hooks.use_memo")

-- TODO FIXME huge issues here.

---@param duration number
---@param default number?
local function use_animated(duration, default)
    local out, set_out = use_state(default)

    local animated = use_memo(function()
        print("new animated")

        return Animated({
            duration = duration,
            target = default,
            subscribed = function(pos)
                set_out(pos)
            end
        })
    end, {})

    local function set_target(target)
        animated:set_target(target)
    end

    return out, set_target
end

return use_animated
