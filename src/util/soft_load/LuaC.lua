
local fs = require("src.util.fs")

---@class Zingle.LuaC : Log.BaseFunctions
---
---@operator call:Zingle.LuaC
local LuaC = class("Zingle.LuaC")

---@param chunk function?
function LuaC:init (chunk)
    if chunk then
        self:set_chunk(chunk)
    end
end

---@param chunk function
function LuaC:set_chunk (chunk)
    self.chunk = chunk

    return self
end

---@param strip boolean
function LuaC:set_strip (strip)
    self.strip = strip

    return self
end

---@param lua_path string
---@return Zingle.LuaC
function LuaC.from_lua_path (lua_path)
    local path, err = package.searchpath(lua_path, package.path)

    if not path then
        error(string.format("Unable to resolve module %q: %s", lua_path, err))
    end

    return LuaC.from_path(path)
end

---@param path string
---@return Zingle.LuaC
function LuaC.from_path (path)
    local contents = fs.read(path)

    local chunk, err = load(contents, path)

    if not chunk then
        error(string.format("Unable to parse module %q: %s", path, err))
    end

    return LuaC(chunk)
end

---@param str string
---@param chunkname any
---@return Zingle.LuaC
function LuaC.from_string (str, chunkname)
    local chunk, err = load(str, chunkname)

    if not chunk then
        error(string.format("Unable to parse string: %s", err))
    end

    return LuaC(chunk)
end

function LuaC:to_string ()
    return string.dump(self.chunk, self.strip)
end

--- Stringify a compiled chunk and write to a file path
---@param outpath string
function LuaC:to_file (outpath)
    local contents = self:to_string()

    fs.write(outpath, contents)
end

return LuaC