local class = require("lib.30log")
local json = require("lib.json")
local fs = require("src.util.fs")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.get_config.type_checker.parse"
local parse = require(folder_of_this_file .. "parse")
---@module "src.util.get_config.type_checker.check"
local check_type = require(folder_of_this_file .. "check")

---@class TypeChecker
---@field types table<string, Type>
---@field new function
local TypeChecker = class("TypeChecker")

function TypeChecker:init()
    self.types = {}
end

--- Add a type
---@param name string the name of the type to add
---@param type Type the type to add
---@return self self so you can chain methods
function TypeChecker:add_type(name, type)
    self.types[name] = type

    return self
end

--- Add a type from a type string
---@param name string the name of the type to add
---@param type_string string the type string to parse into a type
---@return self self so you can chain methods
function TypeChecker:add_type_string(name, type_string)
    self:add_type(name, parse.type_string(type_string))

    return self
end

---@param path string the path to a lua file to parse
---@return self self so you can chain methods
function TypeChecker:add_file(path)
    local contents = fs.read(path)

    if not contents then
        error(string.format("File '%s' not found on disk", path))
    end

    local types = parse.file_string(contents)

    for k, v in pairs(types) do
        self:add_type(k, v)
    end

    return self
end

---@param ... string the paths to lua files to parse
---@return self self so you can chain methods
function TypeChecker:add_files(...)
    for _, path in ipairs({...}) do
        self:add_file(path)
    end
    
    return self
end

---@return string json
function TypeChecker:jsonify_types()
    return json.encode(self.types)
end

---@param desired_type_name string the name of the type we want
---@param to_check any
---@return boolean success, string? error
function TypeChecker:check(desired_type_name, to_check)
    ---@type Type|nil
    local desired_type = self.types[desired_type_name]

    if not desired_type then
        error(string.format("Type '%s' not found in self.types", desired_type_name))
    end

    return check_type(desired_type, to_check, self.types)
end

return TypeChecker