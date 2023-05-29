-- synchronous file system operations

local folder_of_this_file = (...):match("(.-)[^%.]+$")

-- allow src.util.fs.init and src.util.fs
if not folder_of_this_file:match("fs%.") then
    folder_of_this_file = folder_of_this_file .. "fs."
end

---@module "src.util.fs.directories"
local directories = require(folder_of_this_file .. "directories")
---@module "src.util.fs.json"
local json = require(folder_of_this_file .. "json")
---@module "src.util.fs.operations"
local operations = require(folder_of_this_file .. "operations")
---@module "src.util.fs.get_icon"
local get_icon = require(folder_of_this_file .. "get_icon")

return setmetatable({
    directories = directories,

    json = json,

    get_icon = get_icon
}, {
    __index = operations
})