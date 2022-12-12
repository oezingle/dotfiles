
local cli = {}

cli.success = {}

---@enum CLITextColors
cli.colors = {
    RED    = "\27[31m",
    GREEN  = "\27[32m",
    YELLOW = "\27[33m",
    RESET  = "\27[0m",
}

---@enum CLISuccessCharacters
cli.success.characters = {
    UNKNOWN = "?",
    SUCCESS = "✔",
    FAILURE = "✘"
}

---@param success boolean|nil
---@return string
function cli.success.get_color(success)
    if success == nil then
        return cli.colors.YELLOW
    elseif success then
        return cli.colors.GREEN
    else
        return cli.colors.RED
    end
end

--- Get a character that reflects the 
---@param success boolean|nil
---@return string
function cli.success.get_character(success)
    if success == nil then
        return cli.success.characters.UNKNOWN
    elseif success then
        return cli.success.characters.SUCCESS
    else
        return cli.success.characters.FAILURE
    end
end

--- Get character and color
---@param success boolean|nil
---@return string
function cli.success.get(success)
    return cli.success.get_color(success) .. cli.success.get_character(success) .. cli.colors.RESET
end

--- Convert number to percentage 
---@param a number number from 0-100 OR numerator
---@param b number? divisor
---@return string
function cli.to_percent(a, b)
    if not b then
        return tostring(math.floor(a)) .. "%"        
    else
        -- calculate percentage
        local new_a = (a / b) * 100

        return cli.to_percent(new_a)
    end
end

return cli