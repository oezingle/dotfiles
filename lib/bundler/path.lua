local pathlib = {
    -- TODO windows support
    sep = "/",
}

---@param lua_path string
---@return string
function pathlib.from_lua(lua_path)
    local real_path = lua_path:gsub("%.", pathlib.sep)

    return real_path
end

---@param real_path string
---@return string
function pathlib.to_lua(real_path)
    local lua_path = real_path:gsub(pathlib.sep, ".")

    return lua_path
end

return pathlib