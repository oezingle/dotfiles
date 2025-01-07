local join        = require("src.polyfill.path.join")
local dir         = require("src.util.dir")
local lua_version = require("src.polyfill.lua_version")


local has_added = false

---@param path_type "path"|"cpath"
---@param dir string
local function package_path_add(path_type, dir)
    local is_c = path_type == "cpath"

    local extension = is_c and ".so" or ".lua"

    local path = package[path_type]

    -- always include /path/?.ext
    path = path .. ";" .. join(dir, "?" .. extension)

    -- .so files don't have /path/?/init.ext
    if not is_c then
        path = path .. ";" .. join(dir, "?", "init" .. extension)
    end

    package[path_type] = path
end

local function path_add()
    if has_added then
        return
    end

    local home = os.getenv("HOME")

    package_path_add("path", dir.generated.luarocks.share())
    package_path_add("path", join(home, ".luarocks", "share", "lua", lua_version.version))

    package_path_add("cpath", dir.generated.luarocks.lib())
    package_path_add("cpath", join(home, ".luarocks", "lib", "lua", lua_version.version))

    has_added = true
end

return path_add
