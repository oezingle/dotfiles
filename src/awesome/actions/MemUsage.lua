local Action   = require("src.util.Action")
local typed    = require("src.util.typed.typed")

local MemUsage = Action.create("MemUsage", {
    command = "mem-usage",
    -- args = {
    --     typed.Union(typed.Nil(), typed.String("watch"))
    -- },
    -- on_call = function (self)
    --     local mem = collectgarbage("count")
    -- end
})

function MemUsage:on_call(collect)
    -- TODO this but better
    if collect == "collect" then
        collectgarbage("collect")
    end

    -- collectgarbage("step")
    
    local mem = collectgarbage("count")

    local rounded = math.floor(mem)

    self.log.info(string.format("Using %d KiB", rounded))
end

return MemUsage
