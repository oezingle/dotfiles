
--- remove multiline padding from a string
---@param str string
---@return string
local function unpad(str)  
    local transform = str

    local pad = transform:match("^%s-[\n\r]*(%s*)")

    transform = transform
        :gsub(string.format("([\n\r])%s", pad), "%1")
        :gsub("^%s*(.-)[\n\r]?[^%S\n\r]*$", "%1")

    return transform
end

return unpad