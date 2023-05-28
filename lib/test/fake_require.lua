-- require() with 'hot' reloading

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "lib.test.testing_functions"
local library = require(folder_of_this_file .. "testing_functions")
local has_awesome = library.has_awesome

local config_dir = os.getenv("PWD") .. "/"

if has_awesome() then
    local gfs = require("gears.filesystem")
    config_dir = gfs.get_configuration_dir()
end

local function ends_with(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

local function module_path(modname)
    local path = string.gsub(modname, "%.", "/")

    if not ends_with(path, ".lua") then
        path = path .. ".lua"
    end

    return config_dir .. path
end

--- Load a function as if using require() but without using cache
---@param modname string
local function fake_require(modname)
    local paths = { module_path(modname), module_path(modname .. ".init") }
    
    local path = nil
    
    for _, try_path in pairs(paths) do
        local file = io.open(try_path)

        if file then
            file:read(0)

            path = try_path

            file:close()
        end
    end

    if not path then
        -- might exist outside of pwd
        return require(modname)
    else
        return loadfile(path, nil, setmetatable({ 
            require = fake_require
        }, { __index = _ENV }))(modname, path)
    end
end

return fake_require
