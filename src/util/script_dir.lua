
local pwd = require("src.util.fs.pwd").pwd
local join = require("src.polyfill.path.join")
local basename = require("src.polyfill.path.basename")
local fs       = require("src.util.fs")

if table.pack(...)[1] == (arg or {})[1] then
    print "script_dir must be imported"
    os.exit(1)
end

local this_script_relative_path = (...)[2]

local has_gfs, gfs = pcall(require, "gears.filesystem")

local script_dir = {}

-- modified from https://gist.github.com/oezingle/5ce3d893c082252b9ccafa4e73cb41b5
function script_dir.vanilla_lua()
    --- Array[0] seems to not be respected
    ---@type string
    local relative_path = arg[0]

    -- Stupid case here for DOS (windows) machines
    if relative_path:sub(1, 1) == "/" or relative_path:match("^%a:\\") then
        -- This is a full path to the script
        return relative_path
    end

    local full_path = join(pwd(), relative_path)

    return basename(full_path)
end

function script_dir.with_gears()
    return gfs.get_configuration_dir()
end

function script_dir.pwd_and_pray()
    local pwd = os.getenv("PWD")

    if not pwd then
        error("No PWD environment variable")
    end

    if not pwd:match("/$") then
        pwd = pwd .. "/"
    end

    -- TODO FIXME does this not always resolve correctly?
    local this_script = join(pwd, this_script_relative_path)

    assert(fs.exists(this_script), "Unable to verify PWD is correct location")

    return pwd
end

if has_gfs then
    script_dir.script_dir = script_dir.with_gears
-- elseif arg and arg[-1] then
--     script_dir.script_dir = script_dir.vanilla_lua
else
    log.warn("Using PWD for script dir - this may fail!")

    script_dir.script_dir = script_dir.pwd_and_pray
end

return script_dir
