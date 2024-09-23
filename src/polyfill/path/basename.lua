

---@param path string
---@return string
local function path_basename(path)
    -- Path with no slashes, ie just a file
    if not path:match("[/\\]") and path:match("%.") then
        return ""
    end
 
    path = path:gsub("[/\\][^/\\]+%.%S+$", "")

    return path
end

return path_basename