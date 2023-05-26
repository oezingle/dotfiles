
local fs = require("src.util.fs")

local flag_globals = {}

local default_globals = { ["assert"] = true, ["collectgarbage"] = true, ["package"] = true, ["setmetatable"] = true, ["ipairs"] = true, ["_G"] = true, ["arg"] = true, ["rawset"] = true, ["xpcall"] = true, ["_VERSION"] = true, ["os"] = true, ["next"] = true, ["rawlen"] = true, ["loadfile"] = true, ["rawget"] = true, ["print"] = true, ["debug"] = true, ["tonumber"] = true, ["math"] = true, ["table"] = true, ["error"] = true, ["rawequal"] = true, ["select"] = true, ["load"] = true, ["type"] = true, ["pairs"] = true, ["warn"] = true, ["utf8"] = true, ["dofile"] = true, ["tostring"] = true, ["getmetatable"] = true, ["io"] = true, ["string"] = true, ["require"] = true, ["pcall"] = true, ["coroutine"] = true }

function flag_globals.print_default_globals()
    local keys = {}

    for k, _ in pairs(_G) do
        table.insert(keys, string.format("[\"%s\"] = true", k))
    end

    print(string.format("{ %s }", table.concat(keys, ", ")))
end

-- TODO method to set print function

---@return string
local function get_caller ()
    ---@type string|nil   
    local caller = debug.traceback("global_get"):match("global_get[\n\r][^\n\r]+[\n\r][^\n\r]+[\n\r][^\n\r]+[\n\r][%s]+([^%s]+)")

    if not caller then
        error("Your terrible matching function has failed you.\nPossibly due to locale changes, possibly due to lua core changes.\nWho knew that relying on a part of the API you're not supposed to rely on would be stupid?")
    end

    return caller:sub(1, -2)
end

local IGNORE_BUILTIN = false

---@param name string the name of the global variable queried
---@return boolean
local function ignore_global(name)
    if not IGNORE_BUILTIN then 
        return false
    end

    return default_globals[name]
end

--- Return an environment that will print when globals are queried
---@param table table? globals to set here and now
function flag_globals.get_env (table)
    table = table or {}

    return setmetatable(table, {
        __index = function (_, k)
            
            if not ignore_global(k) then
                local caller = get_caller()
    
                print(string.format("In %s: global \"%s\" queried", caller, k))                    
            end

            return _ENV[k]
        end,

        __newindex = function (_, k, v)  
            local caller = get_caller()
            
            print(string.format("In %s: global \"%s\" set to %s", caller, k, tostring(v)))                    

            _ENV[k] = v
        end
    })
end

local USE_PACKAGE_LOADED = false

local module_cache = USE_PACKAGE_LOADED and package.loaded or {}

-- TODO doesn't work under awesome
---@param module string
---@return unknown, unknown loaderdata
function flag_globals.require(module)
    local path = "./" .. module:gsub("%.", "/") .. ".lua"

    if module_cache[module] then
        return module_cache[module], path
    elseif fs.exists(path) then
        local content = fs.read(path)

        if not content then
            error(string.format("File %s exists but can't read", path))
        end

        local chunk = loadfile(path, nil, flag_globals.get_env({
            require = flag_globals.require
        }))(module, path)

        module_cache[module] = chunk

        -- parity with lua fuck you
        return chunk, path
    elseif fs.exists(path:gsub(".lua", "/init.lua")) then
        return flag_globals.require(module .. ".init")
    else
        print(string.format("WARN: '%s' does not load. Falling back on vanilla require()", module))

        return require(module)
    end
end

return flag_globals