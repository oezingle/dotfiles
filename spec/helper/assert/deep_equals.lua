-- https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua

local assert = require("luassert")
local say = require("say")

---@param a any
---@param b any
local function assert_deep_equals(a, b)
    local type_a = type(a)
    local type_b = type(b)

    if type_a ~= type_b then
        return false
    end
    if type(a) ~= "table" then
        return false
    end
    if type(b) ~= "table" then
        return false
    end

    local keys = {}

    for k, v_a in pairs(a) do
        local v_b = b[k]

        if not v_b then
            return false
        end

        if type(v_b) == "table" then
            if not assert_deep_equals(v_a, v_b) then
                return false
            end
        elseif type(v_b) == "function" then
            local d_a = string.dump(v_a, true)
            local d_b = string.dump(v_b, true)

            if not d_a == d_b then
                return false
            end
        else
            if v_a ~= v_b then
                return false
            end
        end

        keys[k] = true
    end

    for k in pairs(b) do
        if not keys[k] then
            return false
        end
    end

    return true
end

--- https://lunarmodules.github.io/busted/#asserts
---@param arguments { [1]: table, [2]: any }
local function deep_equals(state, arguments)
    local a = arguments[1]
    local b = arguments[2]

    if #arguments ~= 2 then
        return false
    end

    return assert_deep_equals(a, b)
end

say:set("assertion.deep_equals.positive", "Expected %s \nto equal %s")
say:set("assertion.deep_equals.negative", "Expected %s \nto equal %s")
assert:register("assertion", "deep_equals", deep_equals, "assertion.deep_equals.positive",
    "assertion.deep_equals.negative")


if false then
    ---@param a table
    ---@param b table
    local function deep_equals(a, b)
    end

    ---@diagnostic disable-next-line:inject-field
    assert.deep_equals = deep_equals
end

return assert.deep_equals
