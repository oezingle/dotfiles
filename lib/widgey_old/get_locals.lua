-- https://stackoverflow.com/questions/2834579/print-all-local-variables-accessible-to-the-current-scope-in-lua

---@param level number?
local function get_locals(level)
    level = level or 2
    
    local variables = {}
    
    local idx = 1

    while true do
        local ln, lv = debug.getlocal(level, idx)
        if ln ~= nil then
            -- Ignore temporary vars in REPL
            if ln:sub(1, 2) ~= "(" then
                variables[ln] = lv                
            end
        else
            break
        end
        idx = 1 + idx
    end

    return variables
end


return get_locals
