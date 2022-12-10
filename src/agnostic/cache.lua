
---@class Cache
---@field new fun(fn: function) create a new cache
---@field get fun(...: any[]) get the cached value for those arguments if possible, or call the callback

---@type Cache
return (function()
    local success, gcache = pcall(require, "gears.cache")

    if success then
        return gcache
    else
        local uncache = require("lib.30log")("Mock Cache")

        function uncache:get(...) 
            return self.fn(...)
        end

        function uncache:init(fn)
            self.fn = fn
        end 

        return uncache
    end
end)()
