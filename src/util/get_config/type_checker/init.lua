
---@alias Primitive nil|number|string|boolean|table|function|thread|userdata

---@class ComplexType
---@field type string

---@alias Type Primitive|ComplexType

local generate = require("src.util.get_config.type_checker.generate")
local parse = require("src.util.get_config.type_checker.parse")
local check_type = require("src.util.get_config.type_checker.check")
local TypeChecker = require("src.util.get_config.type_checker.class")

-- TODO option to bake references to alias

-- TODO enums
-- TODO generics

-- TODO complex functions

local type_checker = setmetatable({
    check = check_type,
    generate = generate,
    parse = parse,
    TypeChecker = TypeChecker
}, {
    ---@return TypeChecker
    __call = function ()
        return TypeChecker()
    end
})

return type_checker
