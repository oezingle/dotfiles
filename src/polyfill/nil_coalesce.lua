
--- from my (unfinished-ish) requiratron project - acts as ?? does in javascript

---@param ... any
local function nil_coalesce(...)
    local args = table.pack(...)
    
    --- #Oops!
    for i=0,#args do
        local element = args[i]

        if element ~= nil then
            return element
        end
    end
end

return nil_coalesce