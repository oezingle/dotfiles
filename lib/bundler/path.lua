local pathlib = {
    -- TODO windows support
    sep = "/",
}

---@param lua_path string
---@return string[] paths [direct, from lua]
function pathlib.from_lua(lua_path)
    local real_path = lua_path:gsub("%.", pathlib.sep)

    return { real_path .. ".lua", real_path .. "/init.lua" }
end

---@param real_path string
---@return string
function pathlib.to_lua(real_path)
    local lua_path = real_path
        -- Remove leading ./
        :gsub("^%./", "")
        -- Remove extension if any
        :gsub("%.[^.]+$", "")
        -- Replace sep with .
        :gsub(pathlib.sep, ".")

    return lua_path
end

--- Find the final extension of a given path
---@param path string
function pathlib.extension(path)
    return path:match("^.+(%..+)$")
end

return pathlib