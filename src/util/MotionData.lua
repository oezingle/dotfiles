local Vector = require("src.util.Vector")

-- TODO maybe lose cache - jerk can just perform velocity & acceleration calculations

---@class Zingle.MotionData : Log.BaseFunctions
---@field data Zingle.Vector[]
---@field size integer
---
---@operator call:Zingle.MotionData
local MotionData = class("Zingle.MotionData")

function MotionData:init(size)
    self.data = {}

    self:set_size(size)
end

function MotionData:recache()
    self.cache = {
        velocity = {},
        acceleration = {}
    }
    for _, t in pairs(self.cache) do
        setmetatable(t, { __mode = "kv" })
    end
end

---@param size integer
---@return self
function MotionData:set_size(size)
    while #self.data < size do
        table.insert(self.data, Vector({ 0, 0, 0 }))
    end

    while #self.data > size do
        table.remove(self.data, 1)
    end

    self.size = size

    self:recache()

    return self
end

---@param position Zingle.Vector
---@return self
function MotionData:insert(position)
    table.insert(self.data, position)
    table.remove(self.data, 1)

    -- TODO is this slow?
    self:recache()

    return self
end

---@param index integer?
---@return Zingle.Vector
function MotionData:position(index)
    index = index or 1

    if index > self.size then
        error(string.format("MotionData of size %d cannot query index %d", self.size, index))
    end

    return self.data[self.size + 1 - index]
end

---@param index integer?
---@return Zingle.Vector
function MotionData:velocity(index)
    index = index or 1

    local cached = self.cache.velocity[index]
    if cached then
        return cached
    end

    -- print(inspect(self.data))

    return self:position(index) - self:position(index + 1)
end

--- https://www.adventuregamestudio.co.uk/forums/beginners-technical-questions/how-could-i-detect-if-mouse-cursor-is-being-shaken/

---@param index integer?
---@return Zingle.Vector
function MotionData:acceleration(index)
    index = index or 1

    local cached = self.cache.acceleration[index]
    if cached then
        return cached
    end

    return self:velocity(index) - self:velocity(index + 1)
end

---@param index integer?
---@return Zingle.Vector
function MotionData:jerk(index)
    index = index or 1

    return self:acceleration(index) - self:acceleration(index + 1)
end

return MotionData
