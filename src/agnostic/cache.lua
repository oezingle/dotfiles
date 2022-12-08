
---@class Cache
---@field new fun(fn: function) create a new cache
---@field get fun(...: any[]) get the cached value for those arguments if possible, or call the callback

---@type Cache
return (function()
    local success, gcache = pcall(require, "gears.cache")

    if success then
        return gcache
    else
        local uncache = {}

        function uncache:get(...) 
            return self.fn(...)
        end

        function uncache:new(fn)
            self.fn = fn
        end 

        return require("src.util.Class")(uncache)
    end
end)()
