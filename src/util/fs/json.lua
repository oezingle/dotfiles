
local json_lib = require("lib.json")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.fs"
local fs = require(folder_of_this_file .. "operations")

local json = {}

--- Load and parse a json file. Throws an error if the file does not exist.
---@param path string
---@return table json
function json.load (path)
    local contents = fs.read(path)

    assert(contents)

    return json_lib.decode(contents)
end

--- Write a table to a json file
---@param path string
---@param table table
function json.dump (path, table)
    local contents = json_lib.encode(table)

    fs.write(path, contents)
end

return json