-- require() with 'hot' reloading

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "lib.test.testing_functions"
local library = require(folder_of_this_file .. "testing_functions")
local has_awesome = library.has_awesome

--- Read a file as a string
---@param path string the file path to read
---@return string|nil contents the file's contents or nil
local function read_file(path)
    local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local config_dir = os.getenv("PWD") .. "/"

if has_awesome() then
    local gfs = require("gears.filesystem")
    config_dir = gfs.get_configuration_dir()
end

local function ends_with(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

local function read_module(modname)
    local path = string.gsub(modname, "%.", "/")

    if not ends_with(path, ".lua") then
        path = path .. ".lua"
    end

    local true_path = config_dir .. path

    return read_file(true_path)
end

--- Load a function as if using require() but without using cache
---@param modname string
local function fake_require(modname)
    local contents = read_module(modname)

    -- try modname + ".init"
    if not contents then
        contents = read_module(modname .. ".init")
    end

    if not contents then
        -- might exist outside of pwd
        return require(modname)
    else
        local inject_require = "local require = require(\"" .. folder_of_this_file .. "fake_require\");"

        return load(inject_require .. contents, modname)(modname)
    end
end

return fake_require
