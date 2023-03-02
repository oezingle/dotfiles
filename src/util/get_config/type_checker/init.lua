
---@alias Primitive nil|number|string|boolean|table|function|thread|userdata

---@class ComplexType
---@field type string

---@alias Type Primitive|ComplexType

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.get_config.type_checker.generate"
local generate = require(folder_of_this_file .. "type_checker.generate")

---@module "src.util.get_config.type_checker.parse"
local parse = require(folder_of_this_file .. "type_checker.parse")

---@module "src.util.get_config.type_checker.check"
local check_type = require(folder_of_this_file .. "type_checker.check")

---@module "src.util.get_config.type_checker.class"
local TypeChecker = require(folder_of_this_file .. "type_checker.class")

-- TODO option to bake references to alias

-- TODO enums
-- TODO generics

-- TODO complex functions

-- TODO handle references using either:
-- - optional third argument for all stored type names
-- - class based approach, where type_checker.check generates an instance for us


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
