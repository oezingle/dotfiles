local sqrt = math.sqrt

-- TODO is 30log class too heavy for this application in any way?

---@class Zingle.Vector : Log.BaseFunctions, number[]
---@field x number
---@field y number
---@field z number
---
---@operator call:Zingle.Vector
local Vector = class("Zingle.Vector")

local xyz = {
    x = 1,
    y = 2,
    z = 3,
}

---@param components number[]
function Vector:init(components)
    components = components or {}

    for i, v in ipairs(components) do
        self[i] = v
    end
end

function Vector:magnitude()
    local sum = 0
    for _, v in ipairs(self) do
        sum = sum + (v ^ 2)
    end

    return sqrt(sum)
end

function Vector.__add(v1, v2)
    local v = Vector()

    for i = 1, math.max(#v1, #v2) do
        local a = v1[i] or 0
        local b = v2[i] or 0

        v[i] = a + b
    end

    return v
end

function Vector.__sub(v1, v2)
    local v = Vector()

    for i = 1, math.max(#v1, #v2) do
        local a = v1[i] or 0
        local b = v2[i] or 0

        v[i] = a - b
    end

    return v
end

Vector.__index = function(vector, key)
    local index = xyz[key]

    if index then
        return rawget(vector, index)
    end

    return rawget(vector, key) or rawget(Vector, key)
end

Vector.__newindex = function(vector, key, value)
    local index = xyz[key]
    if index then
        return rawset(vector, index, value)
    elseif type(key) == "number" then
        return rawset(vector, key, value)
    end

    error(string.format("Key %q cannot be set for Vector", key))
end

return Vector
