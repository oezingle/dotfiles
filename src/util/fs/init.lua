-- synchronous file system operations

local folder_of_this_file = (...):match("(.-)[^%.]+$")

if string.sub(folder_of_this_file, -3) ~= "fs." then
    folder_of_this_file = folder_of_this_file .. "fs."
end

---@module "src.util.fs.directories"
local directories = require(folder_of_this_file .. "directories")
---@module "src.util.fs.json"
local json = require(folder_of_this_file .. "json")
---@module "src.util.fs.operations"
local operations = require(folder_of_this_file .. "operations")

return setmetatable({
    directories = directories,

    json = json
}, {
    __index = operations
})