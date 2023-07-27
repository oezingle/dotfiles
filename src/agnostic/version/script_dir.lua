
---@param args string[]
---@return string
local function script_dir(args)
    if args[2] then
        local dir = args[2]:gsub("/[%a_]+%.lua", "/")
        
        return dir
    else
        -- this is a fallback because debug isn't supposed to be used in 'good lua'
        -- https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
        local str = debug.getinfo(2, "S").source:sub(2)
        return str:match("(.*/)")
    end
end

return script_dir
