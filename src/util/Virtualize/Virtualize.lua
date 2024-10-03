local getfenv                = require("src.polyfill.env.getfenv")
local setfenv                = require("src.polyfill.env.setfenv")
local sep                    = require("lib.LuaX.util.polyfill.path.sep")
local includes               = require("src.polyfill.list.includes")
local reduce                 = require("src.polyfill.list.reduce")
local escape                 = require("src.polyfill.string.escape")
local locked_libraries       = require("src.util.Virtualize.locked_libraries")

---@class Zingle.Virtualize<T> : Log.BaseFunctions, { get_module: (fun(self: self): T) }
---
---@field protected chunk function?
---@field protected env table
---@field protected module_exposed boolean Whether or not get_module() has been called.
---@field protected name string
---
---@field protected read_only_modules table
---
---@operator call:Zingle.Virtualize
local Virtualize             = class("Zingle.Virtualize")

Virtualize.read_only_modules = {}

---@class Zingle.Virtualize.LockableMetatable : metatable
---@field locked boolean

-- path or chunk or function
function Virtualize:init(input)
    self.require_allowed_patterns = {}

    self.metatable = self:get_metatable()
    -- TODO self.env._G is not comprehensive - trying to fix this bug with
    -- self.env._G = self.env will result in bad pairs/ipairs behaviours. boo!
    self.env = setmetatable(self:get_default_env(), self.metatable)

    self.name = "unknown"

    self.module_exposed = false

    if input then
        self:set_input(input)
    end
end

---@param name string
---@return self
function Virtualize:set_name(name)
    self.name = name
    return self
end

---@return string | "unknown"
function Virtualize:get_name()
    return self.name
end

--#region Metatable generation
do
    ---@protected
    ---@return Zingle.Virtualize.LockableMetatable
    function Virtualize:get_metatable()
        -- TODO pairs/ipairs to fix issue with _G
        local mt = { locked = true }

        mt.__index = function(t, k)
            return rawget(t, k)
        end

        mt.__newindex = function(t, k, v)
            if mt.locked then
                error(string.format("assignment to Virtualize<%q> is disallowed - key %q", self.name, tostring(k)))
            else
                rawset(t, k, v)
            end
        end

        return mt
    end

    ---@param name string the name of the function
    function Virtualize:illegal_function(name)
        return function()
            error(string.format("Virtualize<%q> attempted to call illegal function %q", self.name, name))
        end
    end

    ---@protected
    function Virtualize:get_default_env()
        -- creates a new copy on every instantiation, as changes to subtables must not be global.
        -- Extremely secure default
        local default_env = {
            package = {
                loaded = {},
                path = package.path,
                cpath = package.cpath,
                config = package.config,

                -- TODO FIXME side channel attack here?
                searchpath = package.searchpath,

                --[[
                    searchers
                    preload
                    loadlib
                ]]
            },
            arg = {},

            -- errors
            assert = assert,
            error = error,
            pcall = pcall,
            xpcall = xpcall,

            -- types
            tonumber = tonumber,
            tostring = tostring,
            type = type,

            -- tables
            pairs = pairs,
            ipairs = ipairs,
            next = next,
            select = select,
            -- tables: metatables
            setmetatable = setmetatable,
            getmetatable = getmetatable,
            -- tables: raw functions
            rawequal = rawequal,
            rawget = rawget,
            rawlen = rawlen,
            rawset = self:illegal_function("rawset"),

            -- output
            print = print,
            warn = warn,

            collectgarbage = collectgarbage,

            -- TODO FIXME sidechannel - host runs virtual code, virtual code modifies table.insert, host runs said code. env break?
            -- libraries
            ---@diagnostic disable-next-line:undefined-global
            utf8 = locked_libraries.utf8,
            math = locked_libraries.math,
            table = locked_libraries.table,
            string = locked_libraries.string,
            os = {
                difftime = os.difftime,
                clock = os.clock,
                exit = self:illegal_function("os.time"),
                remove = self:illegal_function("os.remove"),
                time = os.time,
                setlocale = self:illegal_function("os.setlocale"),
                date = os.date,
                getenv = self:illegal_function("os.getenv"),
                rename = self:illegal_function("os.rename"),
                tmpname = os.tmpname,
                execute = self:illegal_function("os.execute"),
            },

            _VERSION = _VERSION,

            -- TODO these libraries are libs i deemed likely unsafe - look into it!
            -- coroutine,

            -- lowkey load() might be safe if env defaults to not _G - but test this heavily!
            load = self:illegal_function("load"),
            loadfile = self:illegal_function("loadfile"),
            dofile = self:illegal_function("dofile"),
        }

        ---@param path string
        default_env.require = function(path)
            assert(type(path) == "string", "require path must be a string")

            local loaded = default_env.package.loaded

            if loaded[path] then
                log.debug(string.format("Virtualize %q required preloaded package %q", self.name, path))

                return loaded[path]
            end

            for _, allowed_pattern in ipairs(self.require_allowed_patterns) do
                if path:match(allowed_pattern) then
                    local mod = self.load_from_path(path, self.env)()

                    loaded[path] = mod

                    return mod
                end
            end

            error(string.format("Virtualize %s attempted to require foreign package %q", self.name, path))
        end

        -- TODO see issue in :init
        default_env._G = default_env

        return default_env
    end

    ---@return Zingle.Virtualize
    function Virtualize:unlock_env()
        self.metatable.locked = false

        return self
    end

    ---@return Zingle.Virtualize
    function Virtualize:lock_env()
        self.metatable.locked = true

        return self
    end
end
--#endregion

--#region virtual environment
do
    ---@param environment table?
    function Virtualize:set_env(environment)
        if self.chunk then
            local existing = getfenv(self.chunk)

            if existing ~= self.env then
                if self.module_exposed then
                    -- TODO this error is vague.
                    error("Module has already been exposed - cannot change env of chunk")
                end

                -- in most cases, this won't need to be done retroactively.
                setfenv(self.chunk, self.env)
            end
        end

        if environment then
            -- Destroy old env but keep table referencea
            for k in pairs(self.env) do
                rawset(self.env, k, nil)
            end

            self:add_env(environment)
        end

        return self
    end

    function Virtualize:get_env()
        return self.env
    end

    -- merge the existing environment and this object
    ---@param environment table
    function Virtualize:add_env(environment)
        for k, v in pairs(environment) do
            rawset(self.env, k, v)
        end

        return self
    end
end
--#endregion

--#region virtual environment management
do
    --- **This function may be insecure - Side channel attacks are not prevented.**
    ---
    ---
    --- Copy a module, providing anything that isn't a subtable to users
    ---@param mod string|any
    ---@return table
    function Virtualize.read_only_module(mod)
        if Virtualize.read_only_modules[mod] then
            return Virtualize.read_only_modules[mod]
        end

        local mod = type(mod) == "string" and require(mod) or mod

        local weak_copy = {}

        -- TODO cloning other valus is possible too - just more trivial
        assert(type(mod) == "table", "Virtualize.read_only_module expects a table")

        for k, v in pairs(mod) do
            -- TODO are userdata and thread vulnerable?
            if not includes({ "table", "userdata", "thread" }, type(v)) then
                weak_copy[k] = v
            end
        end

        setmetatable(weak_copy, {
            __newindex = function(t)
                error(string.format("This copy of module %s has been wrapped to be read-only", tostring(t)))
            end,
            -- weak keys and values
            __mode = "kv"
        })

        Virtualize.read_only_modules[mod] = weak_copy

        return weak_copy
    end

    ---@param module string
    function Virtualize:allow_module(module)
        local pattern = "^" .. escape(module) .. "$"

        return self:allow_module_pattern(pattern)
    end

    ---@param start string
    function Virtualize:allow_module_begins_with(start)
        local pattern = "^" .. escape(start)

        return self:allow_module_pattern(pattern)
    end

    ---@param pattern string
    function Virtualize:allow_module_pattern(pattern)
        table.insert(self.require_allowed_patterns, pattern)

        return self
    end

    --- Load a module, safely. Of course, this means there's an overhead.
    --- Creates a new Virtualize instance with defualt settings
    ---@param luapath string
    ---@param mod string | function
    function Virtualize:preload_module_virtualized(luapath, mod)
        if not mod then
            mod = luapath
        end

        return self:preload_module_unsafe(luapath, Virtualize()
            :set_input(mod)
            :set_name(luapath)
            :get_module())
    end

    --- **This function may be insecure - Side channel attacks are not prevented.**
    ---
    --- Preload a module into the environment
    ---@param luapath string
    ---@param mod any
    ---@return self
    function Virtualize:preload_module_read_only(luapath, mod)
        if not mod then
            mod = self.load_from_path(luapath, self.env)()
        end

        local ro = self.read_only_module(mod)

        -- destroy unsafe module
        mod = nil

        return self:preload_module_unsafe(luapath, ro)
    end

    --- **This function is insecure!**
    ---
    --- Preload a module into the environment
    ---@param luapath string
    ---@param mod any
    ---@return self
    function Virtualize:preload_module_unsafe(luapath, mod)
        -- removed because this causes 'safe' functions to behave unsafely if a module returns nil in some environments.
        --[[
        if not mod then
            mod = self.load_from_path(luapath, _G)()
        end
        ]]

        self.env.package.loaded[luapath] = mod

        return self
    end

    --- **This function may be insecure - Side channel attacks are not prevented.**
    ---
    --- Preload a module into the environment, safely
    ---@param path string
    ---@param mod string|any
    ---@return self
    function Virtualize:preload_module(path, mod)
        if path and not mod then
            mod = self.load_from_path(path, self.env)()
        else
            -- TODO FIXME deep copy module

            error("I haven't done this yet")
        end

        return self:preload_module_unsafe(path, mod)
    end

    --- **This function is insecure!**
    ---
    ---@param environment table
    ---@return self
    function Virtualize:with_G(environment)
        log.warn("Adding the global environment to virtual environment. This allows global snooping and modification")

        local env = environment or self.env

        -- This is safe to modification because __setindex is not given
        self.env = setmetatable(env, {
            __index = _G,
            __newindex = self.metatable.__newindex
        })

        return self
    end

    --- > [!WARNING]
    --- > This function is insecure!
    ---
    --- Add _G (global) to environment to self.env, and allow it to be updated in real time
    ---@param environment table
    ---@return self
    function Virtualize:with_live_G(environment)
        log.warn(
            "Adding the live global environment to virtual environment. This allows global snooping, modification, and creation")

        local env = environment or self.env

        self.env = setmetatable(env, {
            __index = _G,
            __newindex = self.metatable.__newindex
        })

        return self
    end
end
--#endregion

--- Like require, but safer.
---@param path string
---@param env table?
---@return function
function Virtualize.load_from_path(path, env)
    if not path:match(sep) then
        -- is not a file path

        -- TODO searchpath here should take env.package.path if it exists.
        local filename, err = package.searchpath(path, package.path .. ";" .. package.cpath)

        if err then
            error(err)
        end

        path = filename --[[ @as string ]]
    end

    local chunk, err = loadfile(path, nil, env)

    if not chunk then
        error(string.format("Error while loading %s: %s", path, err))
    end

    return chunk
end

---@param input string | function
function Virtualize:set_input(input)
    if type(input) == "string" then
        self.chunk = self:string_to_chunk(input)
    elseif type(input) == "function" then
        self.chunk = input

        -- force env onto chunk
        self:set_env()
    else
        error("Virtualize input must be string or function")
    end

    return self
end

---@protected
---@param str string
---@return function
function Virtualize:string_to_chunk(str)
    if str:match("[\n\r]") then
        -- chunk
        local chunk, err = load(str, string.format("Virtualize<%s>", self.name), nil, self.env)

        if err then
            error(string.format("Error while loading: %s", err))
        end

        return chunk --[[@as function]]
    else
        -- path
        local path = str

        self.name = path

        return self.load_from_path(path, self.env)
    end
end

function Virtualize:get_module()
    self.module_exposed = true

    if not self.module then
        self.module = self.chunk()
    end

    return self.module
end

---@param input string|function
---@param globals string[]
---@return Zingle.Virtualize
function Virtualize.with_globals(input, globals)
    return Virtualize()
        :set_env(reduce(globals, function(env, global)
            env[global] = _G[global]

            return env
        end, {}))
        :set_input(input)
end

return Virtualize
