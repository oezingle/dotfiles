local package_manager = require("src.util.package_manager")
local Promise         = require("src.polyfill.Promise")
local join            = require("src.polyfill.path.join")
local dir             = require("src.util.dir")
local lua_version     = require("src.polyfill.lua_version")

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

local function ensure_rocks()
    local home = os.getenv("HOME")

    package_path_add("path", dir.generated.luarocks.share())
    package_path_add("path", join(home, ".luarocks", "share", "lua", lua_version.version))

    package_path_add("cpath", dir.generated.luarocks.lib())
    package_path_add("cpath", join(home, ".luarocks", "lib", "lua", lua_version.version))

    -- print(package.path)
    -- os.exit(0)

    return Promise.all({
        package_manager.rock_install("luafilesystem"),
        package_manager.rock_install("lgi"),
    })
end

return ensure_rocks

--[[
/usr/share/lua/5.3/?.lua
/usr/share/lua/5.3/?/init.lua
/usr/lib/lua/5.3/?.lua
/usr/lib/lua/5.3/?/init.lua
./?.lua
./?/init.lua
/home/zingle/.config/awesome/?.lua
/home/zingle/.config/awesome/?/init.lua
/etc/xdg/awesome/?.lua
/etc/xdg/awesome/?/init.lua
/usr/share/awesome/lib/?.lua
/usr/share/awesome/lib/?/init.lua
/home/zingle/Documents/Code/awesome2/generated/luarocks/share/lua/5.3/?..lua
/home/zingle/Documents/Code/awesome2/generated/luarocks/share/lua/5.3/init..lua
/home/zingle/.luarocks/share/lua/5.3/?..lua
/home/zingle/.luarocks/share/lua/5.3/init..lua
]]
