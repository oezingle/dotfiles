local say = require("say")
local assert = require("luassert")

--- https://lunarmodules.github.io/busted/#asserts
---@param arguments { [1]: table, [2]: any }
local function has_key(state, arguments)
    local table = arguments[1]
    local key = arguments[2]

    if #arguments ~= 2 or not type(table) == "table" then
        return false
    end

    if table[key] then
        return true
    end

    return false
end

say:set("assertion.has_key.positive", "Expected %s \nto have key %s")
say:set("assertion.has_key.negative", "Expected %s \nto have key %s")
assert:register("assertion", "has_key", has_key, "assertion.has_key.positive", "assertion.has_key.negative")

if false then
    ---@param table table
    ---@param key any
    local function has_key(table, key)
    end

    ---@diagnostic disable-next-line:inject-field
    assert.has_key = has_key
end

return assert.has_key