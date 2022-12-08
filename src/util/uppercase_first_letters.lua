--- Make the first letter of all words in a string uppercase. "hello world" -> "Hello World"
---@param str string
---@return string
local function uppercase_first_letters(str)
    return string.gsub(" " .. str, "%W%l", string.upper):sub(2)
end

return uppercase_first_letters