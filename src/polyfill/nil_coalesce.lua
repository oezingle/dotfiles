
--- from my (unfinished-ish) requiratron project - acts as ?? does in javascript

---@generic T
---@alias NilCoalesce.1 fun(a: `T`): T
---@generic T
---@alias NilCoalesce.2 fun(a: nil, b: T): T
---@generic T
---@alias NilCoalesce.3 fun(a: nil, b: nil, c: T): T
---@generic T
---@alias NilCoalesce.4 fun(a: nil, b: nil, c: nil, d: T): T
---@generic T
---@alias NilCoalesce.5 fun(a: nil, b: nil, c: nil, d: nil, e: T): T
---@generic T
---@alias NilCoalesce.6 fun(a: nil, b: nil, c: nil, d: nil, e: nil, f: T): T
---@generic T
---@alias NilCoalesce.7 fun(a: nil, b: nil, c: nil, d: nil, e: nil, f: nil, g: T): T
---@generic T
---@alias NilCoalesce.8 fun(a: nil, b: nil, c: nil, d: nil, e: nil, f: nil, g: nil, h:   T): T


---@alias NilCoalesce NilCoalesce.1 | NilCoalesce.2 | NilCoalesce.3 | NilCoalesce.4 | NilCoalesce.5 | NilCoalesce.6 | NilCoalesce.7 | NilCoalesce.8

-- ---@param ... any
---@type NilCoalesce
local nil_coalesce = function (...)
    local args = table.pack(...)
    
    --- #Oops!
    for i=0,#args do
        local element = args[i]

        if element ~= nil then
            return element
        end
    end

    return nil
end

return nil_coalesce